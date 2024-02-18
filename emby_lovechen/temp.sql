ATTACH DATABASE '/media/config/data/library.org.db' AS xiaoya;
PRAGMA foreign_keys = OFF;
INSERT OR REPLACE INTO MediaItems(
Album,
AlbumId,
ChannelNumber,
CommunityRating,
Container,
CriticRating,
CustomRating,
DateCreated,
DateLastRefreshed,
DateLastSaved,
DateModified,
DisplayOrder,
EndDate,
ExternalId,
ExtraType,
guid,
Height,
Id,
Images,
IndexNumber,
IndexNumberEnd,
InheritedParentalRatingValue,
IsInMixedFolder,
IsKids,
IsLocked,
IsMovie,
IsNews,
IsRepeat,
IsSeries,
IsSports,
IsVirtualItem,
LockedFields,
Name,
OfficialRating,
OriginalTitle,
Overview,
OwnerId,
ParentId,
ParentIndexNumber,
Path,
PreferredMetadataCountryCode,
PreferredMetadataLanguage,
PremiereDate,
PresentationUniqueKey,
ProductionLocations,
ProductionYear,
ProviderIds,
RemoteTrailers,
RunTimeTicks,
SeriesId,
SeriesName,
SeriesPresentationUniqueKey,
Size,
SortIndexNumber,
SortName,
SortParentIndexNumber,
StartDate,
Status,
Tagline,
ThreeDFormat,
TopParentId,
TotalBitrate,
type,
UserDataKeyId,
Width)SELECT 
Album,
AlbumId,
ChannelNumber,
CommunityRating,
Container,
CriticRating,
CustomRating,
DateCreated,
DateLastRefreshed,
DateLastSaved,
DateModified,
DisplayOrder,
EndDate,
ExternalId,
ExtraType,
guid,
Height,
Id,
Images,
IndexNumber,
IndexNumberEnd,
InheritedParentalRatingValue,
IsInMixedFolder,
IsKids,
IsLocked,
IsMovie,
IsNews,
IsRepeat,
IsSeries,
IsSports,
IsVirtualItem,
LockedFields,
Name,
OfficialRating,
OriginalTitle,
Overview,
OwnerId,
ParentId,
ParentIndexNumber,
Path,
PreferredMetadataCountryCode,
PreferredMetadataLanguage,
PremiereDate,
PresentationUniqueKey,
ProductionLocations,
ProductionYear,
ProviderIds,
RemoteTrailers,
RunTimeTicks,
SeriesId,
SeriesName,
SeriesPresentationUniqueKey,
Size,
SortIndexNumber,
SortName,
SortParentIndexNumber,
StartDate,
Status,
Tagline,
ThreeDFormat,
TopParentId,
TotalBitrate,
type,
UserDataKeyId,
Width FROM xiaoya.MediaItems;

INSERT OR REPLACE INTO MediaStreams2(
AspectRatio,
AttachmentSize,
AverageFrameRate,
BitDepth,
BitRate,
ChannelLayout,
Channels,
Codec,
CodecTag,
ColorPrimaries,
ColorSpace,
ColorTransfer,
Comment,
Extradata,
Height,
IsAnamorphic,
IsDefault,
IsExternal,
IsForced,
IsInterlaced,
ItemId,
Language,
Level,
MimeType,
NalLengthSize,
Path,
PixelFormat,
Profile,
RealFrameRate,
RefFrames,
Rotation,
SampleRate,
StreamIndex,
StreamType,
TimeBase,
Title,
Width
)SELECT 
AspectRatio,
AttachmentSize,
AverageFrameRate,
BitDepth,
BitRate,
ChannelLayout,
Channels,
Codec,
CodecTag,
ColorPrimaries,
ColorSpace,
ColorTransfer,
Comment,
Extradata,
Height,
IsAnamorphic,
IsDefault,
IsExternal,
IsForced,
IsInterlaced,
ItemId,
Language,
Level,
MimeType,
NalLengthSize,
Path,
PixelFormat,
Profile,
RealFrameRate,
RefFrames,
Rotation,
SampleRate,
StreamIndex,
StreamType,
TimeBase,
Title,
Width
FROM xiaoya.MediaStreams2;

INSERT OR REPLACE INTO ItemLinks(
ItemId,
LinkedId,
LinkOrder,
Type
)SELECT 
ItemId,
LinkedId,
LinkOrder,
Type
FROM xiaoya.ItemLinks2;

INSERT OR REPLACE INTO ItemPeople(
ItemId,
ListOrder,
PersonId,
PersonType,
Role
)
SELECT 
ItemId,
ListOrder,
PersonId,
PersonType,
Role
FROM xiaoya.ItemPeople2;

INSERT OR REPLACE INTO AncestorIds2(
AncestorId,
ItemId
)
SELECT 
AncestorId,
ItemId
FROM xiaoya.AncestorIds2;

INSERT OR REPLACE INTO fts_search7(Name, OriginalTitle, SeriesName, Album)
SELECT Name, OriginalTitle, SeriesName, Album FROM xiaoya.fts_search8;

INSERT OR REPLACE INTO UserDataKeys2(
Id,
UserDataKey
)
SELECT 
Id,
UserDataKey
FROM xiaoya.UserDataKeys2;

INSERT OR REPLACE INTO Chapters3(
ItemId, ChapterIndex, StartPositionTicks, Name, ImagePath, ImageDateModified, MarkerType
)
SELECT 
ItemId, ChapterIndex, StartPositionTicks, Name, ImagePath, ImageDateModified, MarkerType
FROM xiaoya.Chapters3;

INSERT OR REPLACE INTO ImportedCollections(
ItemId,
Name,
ProviderIds
)
SELECT 
ItemId,
Name,
ProviderIds
FROM xiaoya.ImportedCollections;

DROP TABLE IF EXISTS UserDatas;
CREATE TABLE UserDatas AS SELECT * FROM xiaoya.UserDatas;

INSERT OR REPLACE INTO SyncJobs2(
AudioCodec,
Bitrate,
Category,
Container,
DateCreated,
DateLastModified,
Id,
ItemCount,
ItemLimit,
Name,
ParentId,
Profile,
Progress,
Quality,
Status,
SyncNewContent,
UnwatchedOnly,
UserId,
VideoCodec
)
SELECT 
AudioCodec,
Bitrate,
Category,
Container,
DateCreated,
DateLastModified,
Id,
ItemCount,
ItemLimit,
Name,
ParentId,
Profile,
Progress,
Quality,
Status,
SyncNewContent,
UnwatchedOnly,
UserId,
VideoCodec
FROM xiaoya.SyncJobs2;

INSERT OR REPLACE INTO SyncJobItems2(
AdditionalFiles,
DateCreated,
Id,
ItemId,
ItemName,
JobId,
MediaSource,
MediaSourceId,
OutputPath,
Status,
TemporaryPath
)
SELECT 
AdditionalFiles,
DateCreated,
Id,
ItemId,
ItemName,
JobId,
MediaSource,
MediaSourceId,
OutputPath,
Status,
TemporaryPath
FROM xiaoya.SyncJobItems2;

INSERT OR REPLACE INTO ListItems(
ListId,
ListItemEntryId,
ListItemId,
ListItemOrder
)
SELECT 
ListId,
ListItemEntryId,
ListItemId,
ListItemOrder
FROM xiaoya.ListItems;

INSERT OR REPLACE INTO ItemExtradataTypes(
ExtradataTypeId,
name
)SELECT 
ExtradataTypeId,
name
FROM xiaoya.ItemExtradataTypes;

INSERT OR REPLACE INTO ItemExtradata(
ExtradataTypeId,
ItemId,
Value
)
SELECT 
ExtradataTypeId,
ItemId,
Value
FROM xiaoya.ItemExtradata;

PRAGMA foreign_keys = ON;