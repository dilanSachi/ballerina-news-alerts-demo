import ballerinax/kafka;
import ballerina/log;

final kafka:Producer newsProducer = check new (kafka:DEFAULT_URL);

isolated function produceNewsUpdate(NewsRecord newsRecord) returns error? {
    lock {
        check newsProducer->send({
            topic: publisherTable.get(newsRecord.publisherId).agency,
            value: newsRecord
        });
    }
}

isolated class NewsStreamGenerator {
    private final string consumerGroup;
    private final Agency agency;
    private final kafka:Consumer consumer;

    isolated function init(string consumerGroup, Agency agency) returns error? {
        self.consumerGroup = consumerGroup;
        self.agency = agency;
        kafka:ConsumerConfiguration consumerConfiguration = {
            groupId: consumerGroup,
            offsetReset: kafka:OFFSET_RESET_EARLIEST,
            topics: agency,
            maxPollRecords: 1
        };
        self.consumer = check new (kafka:DEFAULT_URL, consumerConfiguration);
    }

    public isolated function next() returns record {|News value;|}? {
        while true {
            NewsRecord[]|error newsRecords = self.consumer->pollPayload(20);
            if newsRecords is error {
                log:printError("Failed to retrieve data from the Kafka server", newsRecords, id = self.consumerGroup);
                return;
            }
            if newsRecords.length() < 1 {
                log:printWarn(string `No news available in "${self.agency}"`, id = self.consumerGroup);
                continue;
            }
            return {value: new (newsRecords[0])};
        }
    }
}
