//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import <SignalServiceKit/OWSContact.h>
#import <SignalServiceKit/TSInteraction.h>
#import <SignalServiceKit/TSQuotedMessage.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Abstract message class.
 */

@class GRDBReadTransaction;
@class MessageBodyRanges;
@class MessageSticker;
@class OWSLinkPreview;
@class SDSAnyReadTransaction;
@class SDSAnyWriteTransaction;
@class TSAttachment;
@class TSAttachmentStream;
@class TSMessageBuilder;
@class TSQuotedMessage;

@interface TSMessage : TSInteraction <OWSPreviewText>

// NOTE: These correspond to just the "body" attachments.
@property (nonatomic) NSArray<NSString *> *attachmentIds;
@property (nonatomic, readonly, nullable) NSString *body;
@property (nonatomic, readonly, nullable) MessageBodyRanges *bodyRanges;

// Per-conversation expiration.
@property (nonatomic, readonly) uint32_t expiresInSeconds;
@property (nonatomic, readonly) uint64_t expireStartedAt;
@property (nonatomic, readonly) uint64_t expiresAt;
@property (nonatomic, readonly) BOOL hasPerConversationExpiration;
@property (nonatomic, readonly) BOOL hasPerConversationExpirationStarted;

@property (nonatomic, readonly, nullable) TSQuotedMessage *quotedMessage;
@property (nonatomic, readonly, nullable) OWSContact *contactShare;
@property (nonatomic, readonly, nullable) OWSLinkPreview *linkPreview;
@property (nonatomic, readonly, nullable) MessageSticker *messageSticker;

@property (nonatomic, readonly) BOOL isViewOnceMessage;
@property (nonatomic, readonly) BOOL isViewOnceComplete;
@property (nonatomic, readonly) BOOL wasRemotelyDeleted;

- (instancetype)initWithUniqueId:(NSString *)uniqueId
                       timestamp:(uint64_t)timestamp
                          thread:(TSThread *)thread NS_UNAVAILABLE;
- (instancetype)initWithUniqueId:(NSString *)uniqueId
                       timestamp:(uint64_t)timestamp
             receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                          thread:(TSThread *)thread NS_UNAVAILABLE;
- (instancetype)initInteractionWithTimestamp:(uint64_t)timestamp thread:(TSThread *)thread NS_UNAVAILABLE;
- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
           receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                        sortId:(uint64_t)sortId
                     timestamp:(uint64_t)timestamp
                uniqueThreadId:(NSString *)uniqueThreadId NS_UNAVAILABLE;

- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

- (instancetype)initMessageWithBuilder:(TSMessageBuilder *)messageBuilder
NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(messageWithBuilder:));

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
             receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                          sortId:(uint64_t)sortId
                       timestamp:(uint64_t)timestamp
                  uniqueThreadId:(NSString *)uniqueThreadId
                   attachmentIds:(NSArray<NSString *> *)attachmentIds
                            body:(nullable NSString *)body
                      bodyRanges:(nullable MessageBodyRanges *)bodyRanges
                    contactShare:(nullable OWSContact *)contactShare
                 expireStartedAt:(uint64_t)expireStartedAt
                       expiresAt:(uint64_t)expiresAt
                expiresInSeconds:(unsigned int)expiresInSeconds
              isViewOnceComplete:(BOOL)isViewOnceComplete
               isViewOnceMessage:(BOOL)isViewOnceMessage
                     linkPreview:(nullable OWSLinkPreview *)linkPreview
                  messageSticker:(nullable MessageSticker *)messageSticker
                   quotedMessage:(nullable TSQuotedMessage *)quotedMessage
    storedShouldStartExpireTimer:(BOOL)storedShouldStartExpireTimer
              wasRemotelyDeleted:(BOOL)wasRemotelyDeleted
NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(grdbId:uniqueId:receivedAtTimestamp:sortId:timestamp:uniqueThreadId:attachmentIds:body:bodyRanges:contactShare:expireStartedAt:expiresAt:expiresInSeconds:isViewOnceComplete:isViewOnceMessage:linkPreview:messageSticker:quotedMessage:storedShouldStartExpireTimer:wasRemotelyDeleted:));

// clang-format on

// --- CODE GENERATION MARKER

- (BOOL)hasAttachments;
- (NSArray<TSAttachment *> *)bodyAttachmentsWithTransaction:(GRDBReadTransaction *)transaction;
- (BOOL)hasMediaAttachmentsWithTransaction:(GRDBReadTransaction *)transaction;
- (NSArray<TSAttachment *> *)mediaAttachmentsWithTransaction:(GRDBReadTransaction *)transaction;
- (nullable TSAttachment *)oversizeTextAttachmentWithTransaction:(GRDBReadTransaction *)transaction;
- (NSArray<TSAttachment *> *)allAttachmentsWithTransaction:(GRDBReadTransaction *)transaction;

- (void)removeAttachment:(TSAttachment *)attachment
             transaction:(SDSAnyWriteTransaction *)transaction NS_SWIFT_NAME(removeAttachment(_:transaction:));

// Returns ids for all attachments, including message ("body") attachments,
// quoted reply thumbnails, contact share avatars, link preview images, etc.
- (NSArray<NSString *> *)allAttachmentIds;

- (void)setQuotedMessageThumbnailAttachmentStream:(TSAttachmentStream *)attachmentStream;

// The raw body contains placeholders for things like mentions and is not
// user friendly. If you want a constant string representing the body of
// this message, this is it. The `plaintextBody` below will fill in the
// appropriate contact names for a given mention at the time of querying
// providing a more "user friendly" string.
- (nullable NSString *)rawBodyWithTransaction:(GRDBReadTransaction *)transaction;
- (nullable NSString *)plaintextBodyWithTransaction:(GRDBReadTransaction *)transaction;

- (BOOL)shouldStartExpireTimer;

- (BOOL)hasRenderableContent;

#pragma mark - Update With... Methods

- (void)updateWithExpireStartedAt:(uint64_t)expireStartedAt transaction:(SDSAnyWriteTransaction *)transaction;

- (void)updateWithLinkPreview:(OWSLinkPreview *)linkPreview transaction:(SDSAnyWriteTransaction *)transaction;

- (void)updateWithMessageSticker:(MessageSticker *)messageSticker transaction:(SDSAnyWriteTransaction *)transaction;

#ifdef TESTABLE_BUILD

// This method is for testing purposes only.
- (void)updateWithMessageBody:(nullable NSString *)messageBody transaction:(SDSAnyWriteTransaction *)transaction;

#endif

#pragma mark - View Once

- (void)updateWithViewOnceCompleteAndRemoveRenderableContentWithTransaction:(SDSAnyWriteTransaction *)transaction;

#pragma mark - Remote Delete

- (void)updateWithRemotelyDeletedAndRemoveRenderableContentWithTransaction:(SDSAnyWriteTransaction *)transaction;

#pragma mark - Partial Delete

- (void)removeBodyTextWithTransaction:(SDSAnyWriteTransaction *)transaction
    NS_SWIFT_NAME(removeBodyText(transaction:));

- (void)removeMediaAndShareAttachmentsWithTransaction:(SDSAnyWriteTransaction *)transaction
    NS_SWIFT_NAME(removeMediaAndShareAttachments(transaction:));

@end

NS_ASSUME_NONNULL_END
