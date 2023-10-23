# Represents the information of a user that is registered.
# 
# + id - The ID of the user
type User readonly & record {|
    readonly string id;
    *NewUser;
|};

# Represents the information of a user that can be registered.
#
# + name - The name of the user
# + age - The age of the user
type NewUser record {|
    string name;
    int age;
|};

# Represents the information of a publisher that is registered.
# 
# + id - The ID of the publisher
type Publisher readonly & record {|
    readonly string id;
    *NewPublisher;
|};

# Represents the information of a publisher that can be registered.
# 
# + name - The name of the publisher
# + area - The area of the publisher reports news from
# + agency - The news agency of the publisher
type NewPublisher record {|
    string name;
    string area;
    Agency agency;
|};

# Represents a news update that can be published.
# 
# + headline - The headline of the news
# + content - The full content of the news
# + publisherId - The ID of the publisher who published the news
type NewsUpdate record {|
    string headline;
    string content;
    string publisherId;
|};

# Represents a news record that is published.
# 
# + id - The ID of the news update
type NewsRecord readonly & record {|
    readonly string id;
    *NewsUpdate;
|};

# Represents a News that is published.
service class News {
    private final NewsRecord newsRecord;

    isolated function init(NewsRecord newsRecord) {
        self.newsRecord = newsRecord;
    }

    # Retrieves the ID of the news.
    # 
    # + return - The ID of the news
    isolated resource function get id() returns string => self.newsRecord.id;

    # Retrieves the headline of the news.
    # 
    # + return - The headline of the news
    isolated resource function get headline() returns string => self.newsRecord.headline;

    # Retrieves the full content of the news.
    # 
    # + return - The full content of the news
    isolated resource function get content() returns string => self.newsRecord.content;

    # Retrieves the publisher of the news.
    # 
    # + return - The publisher of the news
    isolated resource function get publisher() returns Publisher {
        lock {
            return publisherTable.get(self.newsRecord.publisherId);
        }
    }
}

# The available news agencies.
enum Agency {
    BBC,
    CNN,
    FOX
}
