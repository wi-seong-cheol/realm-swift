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

#import "RLMFindOneAndModifyOptions_Private.hpp"
#import "RLMBSON_Private.hpp"
#import "RLMCollection.h"

@interface RLMFindOneAndModifyOptions() {
    realm::app::MongoCollection::FindOneAndModifyOptions _options;
};
@end

@implementation RLMFindOneAndModifyOptions

- (instancetype)initWithProjection:(id<RLMBSON> _Nullable)projection
                              sort:(id<RLMBSON> _Nullable)sort
                            upsert:(BOOL)upsert
           shouldReturnNewDocument:(BOOL)shouldReturnNewDocument {
    if (self = [super init]) {
        self.upsert = upsert;
        self.shouldReturnNewDocument = shouldReturnNewDocument;
        self.projection = projection;
        self.sort = sort;
    }
    return self;
}

- (instancetype)initWithProjection:(id<RLMBSON> _Nullable)projection
                    sortDescriptor:(NSArray<RLMSortDescriptor *> *)sortDescriptor
                            upsert:(BOOL)upsert
           shouldReturnNewDocument:(BOOL)shouldReturnNewDocument {
    if (self = [super init]) {
        self.upsert = upsert;
        self.shouldReturnNewDocument = shouldReturnNewDocument;
        self.projection = projection;
        self.sortDescriptor = sortDescriptor;
    }
    return self;
}

- (realm::app::MongoCollection::FindOneAndModifyOptions)_findOneAndModifyOptions {
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

- (BOOL)upsert {
    return _options.upsert;
}

- (BOOL)shouldReturnNewDocument {
    return _options.return_new_document;
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

- (void)setUpsert:(BOOL)upsert {
    _options.upsert = upsert;
}

- (void)setShouldReturnNewDocument:(BOOL)returnNewDocument {
    _options.return_new_document = returnNewDocument;
}

@end
