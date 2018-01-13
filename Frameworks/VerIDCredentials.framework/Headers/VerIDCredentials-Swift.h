// Generated by Apple Swift version 4.0.3 (swiftlang-900.0.74.1 clang-900.0.39.2)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_attribute(external_source_symbol)
# define SWIFT_STRINGIFY(str) #str
# define SWIFT_MODULE_NAMESPACE_PUSH(module_name) _Pragma(SWIFT_STRINGIFY(clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in=module_name, generated_declaration))), apply_to=any(function, enum, objc_interface, objc_category, objc_protocol))))
# define SWIFT_MODULE_NAMESPACE_POP _Pragma("clang attribute pop")
#else
# define SWIFT_MODULE_NAMESPACE_PUSH(module_name)
# define SWIFT_MODULE_NAMESPACE_POP
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR __attribute__((enum_extensibility(open)))
# else
#  define SWIFT_ENUM_ATTR
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_ATTR SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if __has_feature(modules)
@import ObjectiveC;
@import Foundation;
@import CoreGraphics;
@import CoreVideo;
@import ImageIO;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

SWIFT_MODULE_NAMESPACE_PUSH("VerIDCredentials")
/// Barcode encoding
typedef SWIFT_ENUM(NSInteger, BarcodeEncoding) {
  BarcodeEncodingAAMVA = 0,
  BarcodeEncodingBC = 1,
  BarcodeEncodingPlain = 2,
};


/// Feature on the card
SWIFT_CLASS("_TtC16VerIDCredentials11CardFeature")
@interface CardFeature : NSObject <NSCopying>
- (id _Nonnull)copyWithZone:(struct _NSZone * _Nullable)zone SWIFT_WARN_UNUSED_RESULT;
/// Expected or detected bounds of the feature (defaults to <code>CGRect.null</code>)
@property (nonatomic, readonly) CGRect bounds;
/// <code>true</code> if the feature was detected in an image
@property (nonatomic, readonly) BOOL detected;
/// Constructor
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

enum BarcodeFormat : NSInteger;

/// Represents a barcode found on an ID card
SWIFT_CLASS("_TtC16VerIDCredentials14BarcodeFeature")
@interface BarcodeFeature : CardFeature
- (id _Nonnull)copyWithZone:(struct _NSZone * _Nullable)zone SWIFT_WARN_UNUSED_RESULT;
/// Format of the barcode
@property (nonatomic, readonly) enum BarcodeFormat format;
/// The way the information in the barcode is encoded
@property (nonatomic, readonly) enum BarcodeEncoding encoding;
/// Raw text detected in the barcode
@property (nonatomic, readonly, copy) NSString * _Nullable payload;
/// Barcode feature constructor
/// \param format Barcode format
///
/// \param encoding Expected barcode encoding
///
- (nonnull instancetype)initWithFormat:(enum BarcodeFormat)format encoding:(enum BarcodeEncoding)encoding OBJC_DESIGNATED_INITIALIZER;
/// Barcode feature constructor with payload
/// \param format Barcode format
///
/// \param payload Detected raw text, encoding will be detected automatically
///
- (nonnull instancetype)initWithFormat:(enum BarcodeFormat)format payload:(NSString * _Nonnull)payload OBJC_DESIGNATED_INITIALIZER;
/// Family name of the cardholder. (Family name is sometimes also called “last name” or “surname.”)
@property (nonatomic, readonly, copy) NSString * _Nullable surname SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.surname' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// First name of the cardholder.
@property (nonatomic, readonly, copy) NSString * _Nullable name SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.name' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Name Suffix (If jurisdiction participates in systems requiring name suffix (PDPS, CDLIS, etc.), the suffix is displayed on the DL/ID and in the MRT).
/// JR (Junior), SR (Senior), 1ST or I (First), 2ND or II (Second), 3RD or III (Third), 4TH or IV (Fourth), 5TH or V (Fifth), 6TH or VI (Sixth), 7TH or VII (Seventh), 8TH or VIII (Eighth), 9TH or IX (Ninth)
@property (nonatomic, readonly, copy) NSString * _Nullable nameSuffix SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.nameSuffix' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Date on which the document was issued.
@property (nonatomic, readonly, copy) NSDate * _Nullable issueDate SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.issueDate' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Date on which the driving and identification privileges granted by the document are no longer valid.
@property (nonatomic, readonly, copy) NSDate * _Nullable expiryDate SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.expiryDate' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Date on which the cardholder was born.
@property (nonatomic, readonly, copy) NSDate * _Nullable dateOfBirth SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.dateOfBirth' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Color of cardholder’s eyes. (ANSI D-20 codes)
@property (nonatomic, readonly, copy) NSString * _Nullable eyeColour SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.eyeColour' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Height of cardholder.
/// Inches (in): number of inches followed by “ in”, ex. 6’1’’ = “073 in”
/// Centimeters (cm): number of centimeters followed by “ cm”, ex. 181 centimeters=“181 cm”
@property (nonatomic, readonly, copy) NSString * _Nullable height SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.height' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Street portion of the cardholder address.
@property (nonatomic, readonly, copy) NSString * _Nullable street1 SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.street1' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Second line of street portion of the cardholder address.
@property (nonatomic, readonly, copy) NSString * _Nullable street2 SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.street2' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// City portion of the cardholder address.
@property (nonatomic, readonly, copy) NSString * _Nullable city SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.city' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// State portion of the cardholder address.
@property (nonatomic, readonly, copy) NSString * _Nullable juridistictionCode SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.juridistictionCode' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Postal code portion of the cardholder address in the U.S. and Canada. If the trailing portion of the postal code in the U.S. is not known, zeros will be used to fill the trailing set of numbers up to nine (9) digits.
@property (nonatomic, readonly, copy) NSString * _Nullable postalCode SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.postalCode' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Country in which DL/ID is issued. U.S. = USA, Canada = CAN.
@property (nonatomic, readonly, copy) NSString * _Nullable country SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.country' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Weight range of the cardholder (kg).
@property (nonatomic, readonly, copy) NSString * _Nullable weight SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.weight' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Number that uniquely identifies a particular document issued to the cardholder from others that may have been issued in the past. This number serves multiple purposes of document discrimination, audit information number, and/or inventory control.
@property (nonatomic, readonly, copy) NSString * _Nullable documentDiscriminator SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.documentDiscriminator' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// The number assigned or calculated by the issuing authority.
@property (nonatomic, readonly, copy) NSString * _Nullable customerIDNumber SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.customerIDNumber' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, copy) NSString * _Nonnull type SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.type' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Generates a string representation of the data detected on the ID card
///
/// returns:
/// Human-readable string
@property (nonatomic, readonly, copy) NSString * _Nonnull string SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.string' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Generates an array representation of the data detected on the ID card
///
/// returns:
/// An array of key-value object pairs
@property (nonatomic, readonly, copy) NSArray<NSDictionary<NSString *, NSString *> *> * _Nonnull array SWIFT_DEPRECATED_OBJC("Swift property 'BarcodeFeature.array' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end

/// Sex/gender
/// <ul>
///   <li>
///     Female
///   </li>
///   <li>
///     Male
///   </li>
/// </ul>
typedef SWIFT_ENUM(NSInteger, Sex) {
  SexFemale = 2,
  SexMale = 1,
};

/// Barcode format
typedef SWIFT_ENUM(NSInteger, BarcodeFormat) {
  BarcodeFormatPDF417 = 0,
};

@class CardFormat;
enum ISOCardFormat : NSInteger;

/// Card with an ISO format
SWIFT_CLASS("_TtC16VerIDCredentials4Card")
@interface Card : NSObject <NSCopying>
- (id _Nonnull)copyWithZone:(struct _NSZone * _Nullable)zone SWIFT_WARN_UNUSED_RESULT;
/// ISO format of the card
@property (nonatomic, readonly, strong) CardFormat * _Nonnull format;
/// Card size in mm
@property (nonatomic) CGSize size;
/// Corner radius of the card in mm
@property (nonatomic) CGFloat cornerRadius;
/// Aspect ratio of the card (w/h)
@property (nonatomic) CGFloat aspectRatio;
/// Features on the card
@property (nonatomic, readonly, copy) NSArray<CardFeature *> * _Nonnull features;
/// Path of the card image relative to the app’s documents directory
@property (nonatomic, copy) NSString * _Nullable imagePath;
/// URL of the image of the card
@property (nonatomic, readonly, copy) NSURL * _Nullable imageURL;
/// Card constructor
/// \param format ISO format of the card
///
/// \param features Features of the card
///
- (nonnull instancetype)initWithFormat:(enum ISOCardFormat)format features:(NSArray<CardFeature *> * _Nonnull)features OBJC_DESIGNATED_INITIALIZER;
/// Indicates whether all features on the card have been detected
@property (nonatomic, readonly) BOOL detected;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end



/// Card format
SWIFT_CLASS("_TtC16VerIDCredentials10CardFormat")
@interface CardFormat : NSObject
/// Aspect ratio width/height of the card
@property (nonatomic, readonly) CGFloat aspectRatio;
/// Format constructor
/// \param size Size of the card in mm
///
/// \param cornerRadius Corner radius of the card in mm
///
- (nonnull instancetype)initWithSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius OBJC_DESIGNATED_INITIALIZER;
/// Construct an ISO ID-1 format
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, strong) CardFormat * _Nonnull id1;)
+ (CardFormat * _Nonnull)id1 SWIFT_WARN_UNUSED_RESULT;
/// Construct an ISO ID-2 format
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, strong) CardFormat * _Nonnull id2;)
+ (CardFormat * _Nonnull)id2 SWIFT_WARN_UNUSED_RESULT;
/// Construct an ISO ID-3 format
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, strong) CardFormat * _Nonnull id3;)
+ (CardFormat * _Nonnull)id3 SWIFT_WARN_UNUSED_RESULT;
/// Calculates the corner radius of the card at the given size
/// \param format Card format
///
/// \param size Size at which to calculate the corner radius
///
///
/// returns:
/// Corner radius relative to the given size
+ (CGFloat)cornerRadiusForCardFormat:(CardFormat * _Nonnull)format atSize:(CGSize)size SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end

@class FacePhotoFeature;

/// Represents a piece of identification like an ID card
SWIFT_CLASS("_TtC16VerIDCredentials8IDBundle")
@interface IDBundle : NSObject <NSCopying>
- (id _Nonnull)copyWithZone:(struct _NSZone * _Nullable)zone SWIFT_WARN_UNUSED_RESULT;
/// The cards in this identification. Each card represents a page of an ID.
@property (nonatomic, readonly, copy) NSArray<Card *> * _Nonnull cards;
/// Construct an ID bundle
/// \param cards Cards in this bundle
///
- (nonnull instancetype)initWithCards:(NSArray<Card *> * _Nonnull)cards OBJC_DESIGNATED_INITIALIZER;
/// Convenience method to get face photo features in the bundle’s cards
@property (nonatomic, readonly, copy) NSDictionary<Card *, NSArray<FacePhotoFeature *> *> * _Nonnull faces;
/// Convenience method to get barcode features in the bundle’s cards
@property (nonatomic, readonly, copy) NSDictionary<Card *, NSArray<BarcodeFeature *> *> * _Nonnull barcodes;
/// Convenient way to get the face photo in the first card of the bundle
@property (nonatomic, readonly, strong) FacePhotoFeature * _Nonnull frontFacePhoto SWIFT_DEPRECATED_OBJC("Swift property 'IDBundle.frontFacePhoto' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end


/// Represents a bundle with one side containing a face photo and another side containing a PDF417 barcode
SWIFT_CLASS("_TtC16VerIDCredentials37DoubleSidedPhotoCardWithPDF417Barcode")
@interface DoubleSidedPhotoCardWithPDF417Barcode : IDBundle
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithCards:(NSArray<Card *> * _Nonnull)cards SWIFT_UNAVAILABLE;
@end

@class NSNumber;
@class VerIDFace;

/// Photograph of a face on a card
SWIFT_CLASS("_TtC16VerIDCredentials16FacePhotoFeature")
@interface FacePhotoFeature : CardFeature
- (id _Nonnull)copyWithZone:(struct _NSZone * _Nullable)zone SWIFT_WARN_UNUSED_RESULT;
/// The face template that can be used for face comparison using Ver-ID
@property (nonatomic, copy, getter=template, setter=setTemplate:) NSArray<NSNumber *> * _Nullable template_;
/// Constructor
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
/// Constructor using a detected face
/// \param face Detected face
///
- (nonnull instancetype)initWithFace:(VerIDFace * _Nonnull)face OBJC_DESIGNATED_INITIALIZER;
@end


@class IDCaptureSessionSettings;
@protocol IDCaptureSessionDelegate;

/// ID capture session
SWIFT_CLASS("_TtC16VerIDCredentials16IDCaptureSession")
@interface IDCaptureSession : NSObject
/// Settings to use in this session
@property (nonatomic, readonly, strong) IDCaptureSessionSettings * _Nonnull settings;
/// The session delegate
@property (nonatomic, weak) id <IDCaptureSessionDelegate> _Nullable delegate;
/// Session identifier. Useful if you have a single delegate handling multiple sessions and you need to distinguish between them.
@property (nonatomic, readonly) NSInteger identifier;
/// Session constructor
/// \param settings Settings to use in this session
///
- (nonnull instancetype)initWithSettings:(IDCaptureSessionSettings * _Nonnull)settings OBJC_DESIGNATED_INITIALIZER;
/// Start the session
- (void)start;
/// Cancel the session
- (void)cancel;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end

@class IDCaptureSessionResult;

/// Delegate for ID capture sessions
SWIFT_PROTOCOL("_TtP16VerIDCredentials24IDCaptureSessionDelegate_")
@protocol IDCaptureSessionDelegate
/// Called when the session finishes. Use the result’s status property to determine the outcome of the session.
/// note:
/// All files associated with the result will be deleted after this call returns. It is your responsibility to copy the files within this call if you need to use them in your app.
/// \param session ID capture session that finished
///
/// \param result Result of the session
///
- (void)idCaptureSession:(IDCaptureSession * _Nonnull)session didFinishWithResult:(IDCaptureSessionResult * _Nonnull)result;
@end

enum IDCaptureSessionStatus : NSInteger;

/// Result of an ID capture session
SWIFT_CLASS("_TtC16VerIDCredentials22IDCaptureSessionResult")
@interface IDCaptureSessionResult : NSObject
/// Detected ID bundle or nil on failure or cancellation
@property (nonatomic, readonly, strong) IDBundle * _Nullable idBundle;
/// Status of the ID capture session
@property (nonatomic, readonly) enum IDCaptureSessionStatus status;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


/// ID capture session settings
SWIFT_CLASS("_TtC16VerIDCredentials24IDCaptureSessionSettings")
@interface IDCaptureSessionSettings : NSObject
/// ID bundle to detect in the session
@property (nonatomic, strong) IDBundle * _Nonnull idBundle;
/// <code>true</code> to show guidance during the session to the user
@property (nonatomic) BOOL showGuide;
/// <code>true</code> to show the result of the session to the user before calling the session’s delegate
@property (nonatomic) BOOL showResult;
/// <code>true</code> if the faces detected in the session will be used for face recognition. <code>false</code> will return faces without face templates that cannot be used for face comparison.
@property (nonatomic) BOOL detectFaceForRecognition;
/// Settings constructor
/// \param idBundle ID bundle to detect in the session, defaults to <code>SingleSidedPhotoCard</code>
///
/// \param showGuide <code>true</code> to show guidance during the session to the user
///
/// \param showResult <code>true</code> to show the result of the session to the user before calling the session’s delegate
///
/// \param detectFaceForRecognition <code>true</code> if the faces detected in the session will be used for face recognition. <code>false</code> will return faces without face templates that cannot be used for face comparison.
///
- (nonnull instancetype)initWithIdBundle:(IDBundle * _Nonnull)idBundle showGuide:(BOOL)showGuide showResult:(BOOL)showResult detectFaceForRecognition:(BOOL)detectFaceForRecognition OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end

typedef SWIFT_ENUM(NSInteger, IDCaptureSessionStatus) {
  IDCaptureSessionStatusFinished = 0,
  IDCaptureSessionStatusFailed = 1,
  IDCaptureSessionStatusCanceled = 2,
};

/// ISO card format
typedef SWIFT_ENUM(NSInteger, ISOCardFormat) {
/// ID-1: Most banking cards and ID cards
  ISOCardFormatId1 = 0,
/// ID-2: French and other ID cards, visas
  ISOCardFormatId2 = 1,
/// ID-3: Passports
  ISOCardFormatId3 = 2,
};


/// ISO ID-1 card with a barcode
SWIFT_CLASS("_TtC16VerIDCredentials27ISOID1CardWithPDF417Barcode")
@interface ISOID1CardWithPDF417Barcode : Card
/// Constructor
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithFormat:(enum ISOCardFormat)format features:(NSArray<CardFeature *> * _Nonnull)features SWIFT_UNAVAILABLE;
@end


/// ISO ID-1 card with a face photo
SWIFT_CLASS("_TtC16VerIDCredentials15ISOID1PhotoCard")
@interface ISOID1PhotoCard : Card
/// Constructor
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
/// Constructor with a detected face
/// \param face Detected face
///
- (nonnull instancetype)initWithFace:(VerIDFace * _Nonnull)face;
- (nonnull instancetype)initWithFormat:(enum ISOCardFormat)format features:(NSArray<CardFeature *> * _Nonnull)features SWIFT_UNAVAILABLE;
@end

@class VNRectangleObservation;

SWIFT_CLASS("_TtC16VerIDCredentials36PerspectiveCorrectionParamsOperation") SWIFT_AVAILABILITY(ios,introduced=11.0)
@interface PerspectiveCorrectionParamsOperation : NSOperation
- (nonnull instancetype)initWithPixelBuffer:(CVImageBufferRef _Nonnull)pixelBuffer orientation:(CGImagePropertyOrientation)orientation rect:(VNRectangleObservation * _Nonnull)rect OBJC_DESIGNATED_INITIALIZER SWIFT_DEPRECATED_OBJC("Swift initializer 'PerspectiveCorrectionParamsOperation.init(pixelBuffer:orientation:rect:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)main;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end

typedef SWIFT_ENUM(NSInteger, Region) {
  RegionUSA = 0,
  RegionCanada = 1,
  RegionEU = 2,
  RegionGeneral = 3,
};


/// Represents a bundle with one side that contains a face photo
SWIFT_CLASS("_TtC16VerIDCredentials20SingleSidedPhotoCard")
@interface SingleSidedPhotoCard : IDBundle
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithCards:(NSArray<Card *> * _Nonnull)cards SWIFT_UNAVAILABLE;
@end

SWIFT_MODULE_NAMESPACE_POP
#pragma clang diagnostic pop
