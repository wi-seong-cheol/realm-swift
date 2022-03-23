////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import "RLMFindOptions_Private.hpp"
#import "RLMBSON_Private.hpp"
#import "RLMCollection.h"

@interface RLMFindOptions() {
    realm::app::MongoCollection::FindOptions _options;
};
@end

@implementation RLMFindOptions

- (instancetype)initWithLimit:(NSInteger)limit
                   projection:(id<RLMBSON> _Nullable)projection
                         sort:(id<RLMBSON> _Nullable)sort {
    if (self = [super init]) {
        self.projection = projection;
        self.sort = sort;
        self.limit = limit;
    }
    return self;
}

- (instancetype)initWithProjection:(id<RLMBSON> _Nullable)projection
                              sort:(id<RLMBSON> _Nullable)sort {
    if (self = [super init]) {
        self.projection = projection;
        self.sort = sort;
    }
    return self;
}

- (instancetype)initWithLimit:(NSInteger)limit
                   projection:(id<RLMBSON> _Nullable)projection
               sortDescriptor:(NSArray<RLMSortDescriptor *> *)sortDescriptor {
    if (self = [super init]) {
        self.projection = projection;
        self.sortDescriptor = sortDescriptor;
        self.limit = limit;
    }
    return self;
}

- (instancetype)initWithProjection:(id<RLMBSON> _Nullable)projection
                    sortDescriptor:(NSArray<RLMSortDescriptor *> *)sortDescriptor {
    if (self = [super init]) {
        self.projection = projection;
        self.sortDescriptor = sortDescriptor;
    }
    return self;
}

- (realm::app::MongoCollection::FindOptions)_findOptions {
    return _options;
}

- (id<RLMBSON>)projection {
    return RLMConvertBsonDocumentToRLMBSON(_options.projection_bson);
}

- (id<RLMBSON>)sort {
    return RLMConvertBsonDocumentToRLMBSON(_options.sort_bson);
}

- (NSArray<RLMSortDescriptor *> *)sortDescriptor {
    id<RLMBSON> rlmBson = RLMConvertBsonDocumentToRLMBSON(_options.sort_bson);
    NSDictionary *bsonDictionary = (NSDictionary<NSString*, NSNumber *> *)rlmBson;
    NSMutableArray<RLMSortDescriptor *> *sortDescriptors = [[NSMutableArray alloc] init];
    [bsonDictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSNumber* value, BOOL* stop) {
        BOOL isAscending = value == [[NSNumber alloc]initWithInteger: 1] ? TRUE : FALSE;
        [sortDescriptors addObject:[RLMSortDescriptor sortDescriptorWithKeyPath:key ascending:isAscending]];
    }];
    return sortDescriptors;
}

- (void)setProjection:(id<RLMBSON>)projection {
    if (projection) {
        auto bson = realm::bson::BsonDocument(RLMConvertRLMBSONToBson(projection));
        _options.projection_bson = realm::util::Optional<realm::bson::BsonDocument>(bson);
    } else {
        _options.projection_bson = realm::util::none;
    }
}

- (void)setSort:(id<RLMBSON>)sort {
    if (sort) {
        auto bson = realm::bson::BsonDocument(RLMConvertRLMBSONToBson(sort));
        _options.sort_bson = realm::util::Optional<realm::bson::BsonDocument>(bson);
    } else {
        _options.sort_bson = realm::util::none;
    }
}

- (void)setSortDescriptor:(NSArray<RLMSortDescriptor *> *)sort {
    if (sort) {
        NSMutableDictionary<NSString *, id<RLMBSON>> *dictionary = [[NSMutableDictionary alloc] init];
        [sort enumerateObjectsUsingBlock:^(RLMSortDescriptor *obj, NSUInteger idx, BOOL *stop) {
            [dictionary setObject:obj.ascending == TRUE ? [[NSNumber alloc]initWithInteger:1] :  [[NSNumber alloc]initWithInteger:-1] forKey:obj.keyPath];
        }];
        auto bson = realm::bson::BsonDocument(RLMConvertRLMBSONToBson(dictionary));
        _options.sort_bson = realm::util::Optional<realm::bson::BsonDocument>(bson);
    } else {
        _options.sort_bson = realm::util::none;
    }
}

- (NSInteger)limit {
    return static_cast<NSInteger>(_options.limit.value_or(0));
}

- (void)setLimit:(NSInteger)limit {
    _options.limit = realm::util::Optional<int64_t>(limit);
}

@end
