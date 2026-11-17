// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 String get id; String get displayName; String get email; String get iconColor;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.iconColor, iconColor) || other.iconColor == iconColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,email,iconColor);

@override
String toString() {
  return 'Profile(id: $id, displayName: $displayName, email: $email, iconColor: $iconColor)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String email, String iconColor
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? email = null,Object? iconColor = null,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,iconColor: null == iconColor ? _self.iconColor : iconColor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String email,  String iconColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.displayName,_that.email,_that.iconColor);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String email,  String iconColor)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.displayName,_that.email,_that.iconColor);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String email,  String iconColor)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.displayName,_that.email,_that.iconColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, required this.displayName, required this.email, this.iconColor = '#F4A261'});
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override final  String displayName;
@override final  String email;
@override@JsonKey() final  String iconColor;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.iconColor, iconColor) || other.iconColor == iconColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,email,iconColor);

@override
String toString() {
  return 'Profile(id: $id, displayName: $displayName, email: $email, iconColor: $iconColor)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String email, String iconColor
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? email = null,Object? iconColor = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,iconColor: null == iconColor ? _self.iconColor : iconColor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserSettings {

 String get userId; int? get lastTeamId; int? get lastBoardId; bool get miniWindowEnabled; bool get googleCalendarLinked;
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<UserSettings> get copyWith => _$UserSettingsCopyWithImpl<UserSettings>(this as UserSettings, _$identity);

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettings&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastTeamId, lastTeamId) || other.lastTeamId == lastTeamId)&&(identical(other.lastBoardId, lastBoardId) || other.lastBoardId == lastBoardId)&&(identical(other.miniWindowEnabled, miniWindowEnabled) || other.miniWindowEnabled == miniWindowEnabled)&&(identical(other.googleCalendarLinked, googleCalendarLinked) || other.googleCalendarLinked == googleCalendarLinked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,lastTeamId,lastBoardId,miniWindowEnabled,googleCalendarLinked);

@override
String toString() {
  return 'UserSettings(userId: $userId, lastTeamId: $lastTeamId, lastBoardId: $lastBoardId, miniWindowEnabled: $miniWindowEnabled, googleCalendarLinked: $googleCalendarLinked)';
}


}

/// @nodoc
abstract mixin class $UserSettingsCopyWith<$Res>  {
  factory $UserSettingsCopyWith(UserSettings value, $Res Function(UserSettings) _then) = _$UserSettingsCopyWithImpl;
@useResult
$Res call({
 String userId, int? lastTeamId, int? lastBoardId, bool miniWindowEnabled, bool googleCalendarLinked
});




}
/// @nodoc
class _$UserSettingsCopyWithImpl<$Res>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._self, this._then);

  final UserSettings _self;
  final $Res Function(UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? lastTeamId = freezed,Object? lastBoardId = freezed,Object? miniWindowEnabled = null,Object? googleCalendarLinked = null,}) {
  return _then(UserSettings(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lastTeamId: freezed == lastTeamId ? _self.lastTeamId : lastTeamId // ignore: cast_nullable_to_non_nullable
as int?,lastBoardId: freezed == lastBoardId ? _self.lastBoardId : lastBoardId // ignore: cast_nullable_to_non_nullable
as int?,miniWindowEnabled: null == miniWindowEnabled ? _self.miniWindowEnabled : miniWindowEnabled // ignore: cast_nullable_to_non_nullable
as bool,googleCalendarLinked: null == googleCalendarLinked ? _self.googleCalendarLinked : googleCalendarLinked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSettings].
extension UserSettingsPatterns on UserSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSettings value)  $default,){
final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSettings value)?  $default,){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int? lastTeamId,  int? lastBoardId,  bool miniWindowEnabled,  bool googleCalendarLinked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.userId,_that.lastTeamId,_that.lastBoardId,_that.miniWindowEnabled,_that.googleCalendarLinked);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int? lastTeamId,  int? lastBoardId,  bool miniWindowEnabled,  bool googleCalendarLinked)  $default,) {final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that.userId,_that.lastTeamId,_that.lastBoardId,_that.miniWindowEnabled,_that.googleCalendarLinked);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int? lastTeamId,  int? lastBoardId,  bool miniWindowEnabled,  bool googleCalendarLinked)?  $default,) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.userId,_that.lastTeamId,_that.lastBoardId,_that.miniWindowEnabled,_that.googleCalendarLinked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSettings implements UserSettings {
  const _UserSettings({required this.userId, this.lastTeamId, this.lastBoardId, this.miniWindowEnabled = true, this.googleCalendarLinked = false});
  factory _UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

@override final  String userId;
@override final  int? lastTeamId;
@override final  int? lastBoardId;
@override@JsonKey() final  bool miniWindowEnabled;
@override@JsonKey() final  bool googleCalendarLinked;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsCopyWith<_UserSettings> get copyWith => __$UserSettingsCopyWithImpl<_UserSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettings&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastTeamId, lastTeamId) || other.lastTeamId == lastTeamId)&&(identical(other.lastBoardId, lastBoardId) || other.lastBoardId == lastBoardId)&&(identical(other.miniWindowEnabled, miniWindowEnabled) || other.miniWindowEnabled == miniWindowEnabled)&&(identical(other.googleCalendarLinked, googleCalendarLinked) || other.googleCalendarLinked == googleCalendarLinked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,lastTeamId,lastBoardId,miniWindowEnabled,googleCalendarLinked);

@override
String toString() {
  return 'UserSettings(userId: $userId, lastTeamId: $lastTeamId, lastBoardId: $lastBoardId, miniWindowEnabled: $miniWindowEnabled, googleCalendarLinked: $googleCalendarLinked)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsCopyWith<$Res> implements $UserSettingsCopyWith<$Res> {
  factory _$UserSettingsCopyWith(_UserSettings value, $Res Function(_UserSettings) _then) = __$UserSettingsCopyWithImpl;
@override @useResult
$Res call({
 String userId, int? lastTeamId, int? lastBoardId, bool miniWindowEnabled, bool googleCalendarLinked
});




}
/// @nodoc
class __$UserSettingsCopyWithImpl<$Res>
    implements _$UserSettingsCopyWith<$Res> {
  __$UserSettingsCopyWithImpl(this._self, this._then);

  final _UserSettings _self;
  final $Res Function(_UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? lastTeamId = freezed,Object? lastBoardId = freezed,Object? miniWindowEnabled = null,Object? googleCalendarLinked = null,}) {
  return _then(_UserSettings(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lastTeamId: freezed == lastTeamId ? _self.lastTeamId : lastTeamId // ignore: cast_nullable_to_non_nullable
as int?,lastBoardId: freezed == lastBoardId ? _self.lastBoardId : lastBoardId // ignore: cast_nullable_to_non_nullable
as int?,miniWindowEnabled: null == miniWindowEnabled ? _self.miniWindowEnabled : miniWindowEnabled // ignore: cast_nullable_to_non_nullable
as bool,googleCalendarLinked: null == googleCalendarLinked ? _self.googleCalendarLinked : googleCalendarLinked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Team {

 int get teamId; String get name; String? get description; String get ownerUserId;
/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamCopyWith<Team> get copyWith => _$TeamCopyWithImpl<Team>(this as Team, _$identity);

  /// Serializes this Team to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Team&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.ownerUserId, ownerUserId) || other.ownerUserId == ownerUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,name,description,ownerUserId);

@override
String toString() {
  return 'Team(teamId: $teamId, name: $name, description: $description, ownerUserId: $ownerUserId)';
}


}

/// @nodoc
abstract mixin class $TeamCopyWith<$Res>  {
  factory $TeamCopyWith(Team value, $Res Function(Team) _then) = _$TeamCopyWithImpl;
@useResult
$Res call({
 int teamId, String name, String? description, String ownerUserId
});




}
/// @nodoc
class _$TeamCopyWithImpl<$Res>
    implements $TeamCopyWith<$Res> {
  _$TeamCopyWithImpl(this._self, this._then);

  final Team _self;
  final $Res Function(Team) _then;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,Object? name = null,Object? description = freezed,Object? ownerUserId = null,}) {
  return _then(Team(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Team].
extension TeamPatterns on Team {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Team value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Team value)  $default,){
final _that = this;
switch (_that) {
case _Team():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Team value)?  $default,){
final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int teamId,  String name,  String? description,  String ownerUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that.teamId,_that.name,_that.description,_that.ownerUserId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int teamId,  String name,  String? description,  String ownerUserId)  $default,) {final _that = this;
switch (_that) {
case _Team():
return $default(_that.teamId,_that.name,_that.description,_that.ownerUserId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int teamId,  String name,  String? description,  String ownerUserId)?  $default,) {final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that.teamId,_that.name,_that.description,_that.ownerUserId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Team implements Team {
  const _Team({required this.teamId, required this.name, this.description, required this.ownerUserId});
  factory _Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

@override final  int teamId;
@override final  String name;
@override final  String? description;
@override final  String ownerUserId;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamCopyWith<_Team> get copyWith => __$TeamCopyWithImpl<_Team>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Team&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.ownerUserId, ownerUserId) || other.ownerUserId == ownerUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,name,description,ownerUserId);

@override
String toString() {
  return 'Team(teamId: $teamId, name: $name, description: $description, ownerUserId: $ownerUserId)';
}


}

/// @nodoc
abstract mixin class _$TeamCopyWith<$Res> implements $TeamCopyWith<$Res> {
  factory _$TeamCopyWith(_Team value, $Res Function(_Team) _then) = __$TeamCopyWithImpl;
@override @useResult
$Res call({
 int teamId, String name, String? description, String ownerUserId
});




}
/// @nodoc
class __$TeamCopyWithImpl<$Res>
    implements _$TeamCopyWith<$Res> {
  __$TeamCopyWithImpl(this._self, this._then);

  final _Team _self;
  final $Res Function(_Team) _then;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,Object? name = null,Object? description = freezed,Object? ownerUserId = null,}) {
  return _then(_Team(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TeamMember {

 int get teamMemberId; int get teamId; String get userId; TeamRole get role; DateTime? get leftAt;@JsonKey(name: 'profiles') Profile? get profile;
/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamMemberCopyWith<TeamMember> get copyWith => _$TeamMemberCopyWithImpl<TeamMember>(this as TeamMember, _$identity);

  /// Serializes this TeamMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamMember&&(identical(other.teamMemberId, teamMemberId) || other.teamMemberId == teamMemberId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamMemberId,teamId,userId,role,leftAt,profile);

@override
String toString() {
  return 'TeamMember(teamMemberId: $teamMemberId, teamId: $teamId, userId: $userId, role: $role, leftAt: $leftAt, profile: $profile)';
}


}

/// @nodoc
abstract mixin class $TeamMemberCopyWith<$Res>  {
  factory $TeamMemberCopyWith(TeamMember value, $Res Function(TeamMember) _then) = _$TeamMemberCopyWithImpl;
@useResult
$Res call({
 int teamMemberId, int teamId, String userId, TeamRole role, DateTime? leftAt,@JsonKey(name: 'profiles') Profile? profile
});


$ProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$TeamMemberCopyWithImpl<$Res>
    implements $TeamMemberCopyWith<$Res> {
  _$TeamMemberCopyWithImpl(this._self, this._then);

  final TeamMember _self;
  final $Res Function(TeamMember) _then;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamMemberId = null,Object? teamId = null,Object? userId = null,Object? role = null,Object? leftAt = freezed,Object? profile = freezed,}) {
  return _then(TeamMember(
teamMemberId: null == teamMemberId ? _self.teamMemberId : teamMemberId // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TeamRole,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as DateTime?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile?,
  ));
}
/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [TeamMember].
extension TeamMemberPatterns on TeamMember {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamMember value)  $default,){
final _that = this;
switch (_that) {
case _TeamMember():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamMember value)?  $default,){
final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int teamMemberId,  int teamId,  String userId,  TeamRole role,  DateTime? leftAt, @JsonKey(name: 'profiles')  Profile? profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that.teamMemberId,_that.teamId,_that.userId,_that.role,_that.leftAt,_that.profile);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int teamMemberId,  int teamId,  String userId,  TeamRole role,  DateTime? leftAt, @JsonKey(name: 'profiles')  Profile? profile)  $default,) {final _that = this;
switch (_that) {
case _TeamMember():
return $default(_that.teamMemberId,_that.teamId,_that.userId,_that.role,_that.leftAt,_that.profile);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int teamMemberId,  int teamId,  String userId,  TeamRole role,  DateTime? leftAt, @JsonKey(name: 'profiles')  Profile? profile)?  $default,) {final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that.teamMemberId,_that.teamId,_that.userId,_that.role,_that.leftAt,_that.profile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamMember extends TeamMember {
  const _TeamMember({required this.teamMemberId, required this.teamId, required this.userId, required this.role, this.leftAt, @JsonKey(name: 'profiles') this.profile}): super._();
  factory _TeamMember.fromJson(Map<String, dynamic> json) => _$TeamMemberFromJson(json);

@override final  int teamMemberId;
@override final  int teamId;
@override final  String userId;
@override final  TeamRole role;
@override final  DateTime? leftAt;
@override@JsonKey(name: 'profiles') final  Profile? profile;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamMemberCopyWith<_TeamMember> get copyWith => __$TeamMemberCopyWithImpl<_TeamMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamMember&&(identical(other.teamMemberId, teamMemberId) || other.teamMemberId == teamMemberId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamMemberId,teamId,userId,role,leftAt,profile);

@override
String toString() {
  return 'TeamMember(teamMemberId: $teamMemberId, teamId: $teamId, userId: $userId, role: $role, leftAt: $leftAt, profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$TeamMemberCopyWith<$Res> implements $TeamMemberCopyWith<$Res> {
  factory _$TeamMemberCopyWith(_TeamMember value, $Res Function(_TeamMember) _then) = __$TeamMemberCopyWithImpl;
@override @useResult
$Res call({
 int teamMemberId, int teamId, String userId, TeamRole role, DateTime? leftAt,@JsonKey(name: 'profiles') Profile? profile
});


@override $ProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$TeamMemberCopyWithImpl<$Res>
    implements _$TeamMemberCopyWith<$Res> {
  __$TeamMemberCopyWithImpl(this._self, this._then);

  final _TeamMember _self;
  final $Res Function(_TeamMember) _then;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamMemberId = null,Object? teamId = null,Object? userId = null,Object? role = null,Object? leftAt = freezed,Object? profile = freezed,}) {
  return _then(_TeamMember(
teamMemberId: null == teamMemberId ? _self.teamMemberId : teamMemberId // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TeamRole,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as DateTime?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile?,
  ));
}

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$Board {

 int get boardId; int get teamId; String get name;
/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardCopyWith<Board> get copyWith => _$BoardCopyWithImpl<Board>(this as Board, _$identity);

  /// Serializes this Board to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Board&&(identical(other.boardId, boardId) || other.boardId == boardId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,boardId,teamId,name);

@override
String toString() {
  return 'Board(boardId: $boardId, teamId: $teamId, name: $name)';
}


}

/// @nodoc
abstract mixin class $BoardCopyWith<$Res>  {
  factory $BoardCopyWith(Board value, $Res Function(Board) _then) = _$BoardCopyWithImpl;
@useResult
$Res call({
 int boardId, int teamId, String name
});




}
/// @nodoc
class _$BoardCopyWithImpl<$Res>
    implements $BoardCopyWith<$Res> {
  _$BoardCopyWithImpl(this._self, this._then);

  final Board _self;
  final $Res Function(Board) _then;

/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? boardId = null,Object? teamId = null,Object? name = null,}) {
  return _then(Board(
boardId: null == boardId ? _self.boardId : boardId // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Board].
extension BoardPatterns on Board {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Board value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Board() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Board value)  $default,){
final _that = this;
switch (_that) {
case _Board():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Board value)?  $default,){
final _that = this;
switch (_that) {
case _Board() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int boardId,  int teamId,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Board() when $default != null:
return $default(_that.boardId,_that.teamId,_that.name);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int boardId,  int teamId,  String name)  $default,) {final _that = this;
switch (_that) {
case _Board():
return $default(_that.boardId,_that.teamId,_that.name);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int boardId,  int teamId,  String name)?  $default,) {final _that = this;
switch (_that) {
case _Board() when $default != null:
return $default(_that.boardId,_that.teamId,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Board implements Board {
  const _Board({required this.boardId, required this.teamId, required this.name});
  factory _Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);

@override final  int boardId;
@override final  int teamId;
@override final  String name;

/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardCopyWith<_Board> get copyWith => __$BoardCopyWithImpl<_Board>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Board&&(identical(other.boardId, boardId) || other.boardId == boardId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,boardId,teamId,name);

@override
String toString() {
  return 'Board(boardId: $boardId, teamId: $teamId, name: $name)';
}


}

/// @nodoc
abstract mixin class _$BoardCopyWith<$Res> implements $BoardCopyWith<$Res> {
  factory _$BoardCopyWith(_Board value, $Res Function(_Board) _then) = __$BoardCopyWithImpl;
@override @useResult
$Res call({
 int boardId, int teamId, String name
});




}
/// @nodoc
class __$BoardCopyWithImpl<$Res>
    implements _$BoardCopyWith<$Res> {
  __$BoardCopyWithImpl(this._self, this._then);

  final _Board _self;
  final $Res Function(_Board) _then;

/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? boardId = null,Object? teamId = null,Object? name = null,}) {
  return _then(_Board(
boardId: null == boardId ? _self.boardId : boardId // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TaskAssignee {

 int get taskMemberId; String get userId;
/// Create a copy of TaskAssignee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskAssigneeCopyWith<TaskAssignee> get copyWith => _$TaskAssigneeCopyWithImpl<TaskAssignee>(this as TaskAssignee, _$identity);

  /// Serializes this TaskAssignee to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskAssignee&&(identical(other.taskMemberId, taskMemberId) || other.taskMemberId == taskMemberId)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskMemberId,userId);

@override
String toString() {
  return 'TaskAssignee(taskMemberId: $taskMemberId, userId: $userId)';
}


}

/// @nodoc
abstract mixin class $TaskAssigneeCopyWith<$Res>  {
  factory $TaskAssigneeCopyWith(TaskAssignee value, $Res Function(TaskAssignee) _then) = _$TaskAssigneeCopyWithImpl;
@useResult
$Res call({
 int taskMemberId, String userId
});




}
/// @nodoc
class _$TaskAssigneeCopyWithImpl<$Res>
    implements $TaskAssigneeCopyWith<$Res> {
  _$TaskAssigneeCopyWithImpl(this._self, this._then);

  final TaskAssignee _self;
  final $Res Function(TaskAssignee) _then;

/// Create a copy of TaskAssignee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskMemberId = null,Object? userId = null,}) {
  return _then(TaskAssignee(
taskMemberId: null == taskMemberId ? _self.taskMemberId : taskMemberId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskAssignee].
extension TaskAssigneePatterns on TaskAssignee {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskAssignee value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskAssignee() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskAssignee value)  $default,){
final _that = this;
switch (_that) {
case _TaskAssignee():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskAssignee value)?  $default,){
final _that = this;
switch (_that) {
case _TaskAssignee() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int taskMemberId,  String userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskAssignee() when $default != null:
return $default(_that.taskMemberId,_that.userId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int taskMemberId,  String userId)  $default,) {final _that = this;
switch (_that) {
case _TaskAssignee():
return $default(_that.taskMemberId,_that.userId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int taskMemberId,  String userId)?  $default,) {final _that = this;
switch (_that) {
case _TaskAssignee() when $default != null:
return $default(_that.taskMemberId,_that.userId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskAssignee implements TaskAssignee {
  const _TaskAssignee({required this.taskMemberId, required this.userId});
  factory _TaskAssignee.fromJson(Map<String, dynamic> json) => _$TaskAssigneeFromJson(json);

@override final  int taskMemberId;
@override final  String userId;

/// Create a copy of TaskAssignee
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskAssigneeCopyWith<_TaskAssignee> get copyWith => __$TaskAssigneeCopyWithImpl<_TaskAssignee>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskAssigneeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskAssignee&&(identical(other.taskMemberId, taskMemberId) || other.taskMemberId == taskMemberId)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskMemberId,userId);

@override
String toString() {
  return 'TaskAssignee(taskMemberId: $taskMemberId, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$TaskAssigneeCopyWith<$Res> implements $TaskAssigneeCopyWith<$Res> {
  factory _$TaskAssigneeCopyWith(_TaskAssignee value, $Res Function(_TaskAssignee) _then) = __$TaskAssigneeCopyWithImpl;
@override @useResult
$Res call({
 int taskMemberId, String userId
});




}
/// @nodoc
class __$TaskAssigneeCopyWithImpl<$Res>
    implements _$TaskAssigneeCopyWith<$Res> {
  __$TaskAssigneeCopyWithImpl(this._self, this._then);

  final _TaskAssignee _self;
  final $Res Function(_TaskAssignee) _then;

/// Create a copy of TaskAssignee
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskMemberId = null,Object? userId = null,}) {
  return _then(_TaskAssignee(
taskMemberId: null == taskMemberId ? _self.taskMemberId : taskMemberId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Task {

 int get taskId; int get teamId; int get boardId; String get title; String? get description; DateTime? get startAt; bool get startHasTime; DateTime? get dueAt; bool get dueHasTime; TaskPriority get priority; TaskStatus get status; double get posX; double get posY; String get color; TaskSize get size; String? get latestComment; String? get latestCommentBy; DateTime? get latestCommentAt; String get createdBy; DateTime? get completedAt; String? get completedBy; DateTime? get reviewedAt; DateTime? get returnedAt; DateTime? get deletedAt; DateTime? get createdAt; DateTime? get updatedAt;@JsonKey(name: 'task_members') List<TaskAssignee> get assignees;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.boardId, boardId) || other.boardId == boardId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.startHasTime, startHasTime) || other.startHasTime == startHasTime)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.dueHasTime, dueHasTime) || other.dueHasTime == dueHasTime)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.posX, posX) || other.posX == posX)&&(identical(other.posY, posY) || other.posY == posY)&&(identical(other.color, color) || other.color == color)&&(identical(other.size, size) || other.size == size)&&(identical(other.latestComment, latestComment) || other.latestComment == latestComment)&&(identical(other.latestCommentBy, latestCommentBy) || other.latestCommentBy == latestCommentBy)&&(identical(other.latestCommentAt, latestCommentAt) || other.latestCommentAt == latestCommentAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.completedBy, completedBy) || other.completedBy == completedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.returnedAt, returnedAt) || other.returnedAt == returnedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.assignees, assignees));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,taskId,teamId,boardId,title,description,startAt,startHasTime,dueAt,dueHasTime,priority,status,posX,posY,color,size,latestComment,latestCommentBy,latestCommentAt,createdBy,completedAt,completedBy,reviewedAt,returnedAt,deletedAt,createdAt,updatedAt,const DeepCollectionEquality().hash(assignees)]);

@override
String toString() {
  return 'Task(taskId: $taskId, teamId: $teamId, boardId: $boardId, title: $title, description: $description, startAt: $startAt, startHasTime: $startHasTime, dueAt: $dueAt, dueHasTime: $dueHasTime, priority: $priority, status: $status, posX: $posX, posY: $posY, color: $color, size: $size, latestComment: $latestComment, latestCommentBy: $latestCommentBy, latestCommentAt: $latestCommentAt, createdBy: $createdBy, completedAt: $completedAt, completedBy: $completedBy, reviewedAt: $reviewedAt, returnedAt: $returnedAt, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt, assignees: $assignees)';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 int taskId, int teamId, int boardId, String title, String? description, DateTime? startAt, bool startHasTime, DateTime? dueAt, bool dueHasTime, TaskPriority priority, TaskStatus status, double posX, double posY, String color, TaskSize size, String? latestComment, String? latestCommentBy, DateTime? latestCommentAt, String createdBy, DateTime? completedAt, String? completedBy, DateTime? reviewedAt, DateTime? returnedAt, DateTime? deletedAt, DateTime? createdAt, DateTime? updatedAt,@JsonKey(name: 'task_members') List<TaskAssignee> assignees
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,Object? teamId = null,Object? boardId = null,Object? title = null,Object? description = freezed,Object? startAt = freezed,Object? startHasTime = null,Object? dueAt = freezed,Object? dueHasTime = null,Object? priority = null,Object? status = null,Object? posX = null,Object? posY = null,Object? color = null,Object? size = null,Object? latestComment = freezed,Object? latestCommentBy = freezed,Object? latestCommentAt = freezed,Object? createdBy = null,Object? completedAt = freezed,Object? completedBy = freezed,Object? reviewedAt = freezed,Object? returnedAt = freezed,Object? deletedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? assignees = null,}) {
  return _then(Task(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,boardId: null == boardId ? _self.boardId : boardId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startHasTime: null == startHasTime ? _self.startHasTime : startHasTime // ignore: cast_nullable_to_non_nullable
as bool,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dueHasTime: null == dueHasTime ? _self.dueHasTime : dueHasTime // ignore: cast_nullable_to_non_nullable
as bool,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,posX: null == posX ? _self.posX : posX // ignore: cast_nullable_to_non_nullable
as double,posY: null == posY ? _self.posY : posY // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as TaskSize,latestComment: freezed == latestComment ? _self.latestComment : latestComment // ignore: cast_nullable_to_non_nullable
as String?,latestCommentBy: freezed == latestCommentBy ? _self.latestCommentBy : latestCommentBy // ignore: cast_nullable_to_non_nullable
as String?,latestCommentAt: freezed == latestCommentAt ? _self.latestCommentAt : latestCommentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedBy: freezed == completedBy ? _self.completedBy : completedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,assignees: null == assignees ? _self.assignees : assignees // ignore: cast_nullable_to_non_nullable
as List<TaskAssignee>,
  ));
}

}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int taskId,  int teamId,  int boardId,  String title,  String? description,  DateTime? startAt,  bool startHasTime,  DateTime? dueAt,  bool dueHasTime,  TaskPriority priority,  TaskStatus status,  double posX,  double posY,  String color,  TaskSize size,  String? latestComment,  String? latestCommentBy,  DateTime? latestCommentAt,  String createdBy,  DateTime? completedAt,  String? completedBy,  DateTime? reviewedAt,  DateTime? returnedAt,  DateTime? deletedAt,  DateTime? createdAt,  DateTime? updatedAt, @JsonKey(name: 'task_members')  List<TaskAssignee> assignees)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.taskId,_that.teamId,_that.boardId,_that.title,_that.description,_that.startAt,_that.startHasTime,_that.dueAt,_that.dueHasTime,_that.priority,_that.status,_that.posX,_that.posY,_that.color,_that.size,_that.latestComment,_that.latestCommentBy,_that.latestCommentAt,_that.createdBy,_that.completedAt,_that.completedBy,_that.reviewedAt,_that.returnedAt,_that.deletedAt,_that.createdAt,_that.updatedAt,_that.assignees);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int taskId,  int teamId,  int boardId,  String title,  String? description,  DateTime? startAt,  bool startHasTime,  DateTime? dueAt,  bool dueHasTime,  TaskPriority priority,  TaskStatus status,  double posX,  double posY,  String color,  TaskSize size,  String? latestComment,  String? latestCommentBy,  DateTime? latestCommentAt,  String createdBy,  DateTime? completedAt,  String? completedBy,  DateTime? reviewedAt,  DateTime? returnedAt,  DateTime? deletedAt,  DateTime? createdAt,  DateTime? updatedAt, @JsonKey(name: 'task_members')  List<TaskAssignee> assignees)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.taskId,_that.teamId,_that.boardId,_that.title,_that.description,_that.startAt,_that.startHasTime,_that.dueAt,_that.dueHasTime,_that.priority,_that.status,_that.posX,_that.posY,_that.color,_that.size,_that.latestComment,_that.latestCommentBy,_that.latestCommentAt,_that.createdBy,_that.completedAt,_that.completedBy,_that.reviewedAt,_that.returnedAt,_that.deletedAt,_that.createdAt,_that.updatedAt,_that.assignees);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int taskId,  int teamId,  int boardId,  String title,  String? description,  DateTime? startAt,  bool startHasTime,  DateTime? dueAt,  bool dueHasTime,  TaskPriority priority,  TaskStatus status,  double posX,  double posY,  String color,  TaskSize size,  String? latestComment,  String? latestCommentBy,  DateTime? latestCommentAt,  String createdBy,  DateTime? completedAt,  String? completedBy,  DateTime? reviewedAt,  DateTime? returnedAt,  DateTime? deletedAt,  DateTime? createdAt,  DateTime? updatedAt, @JsonKey(name: 'task_members')  List<TaskAssignee> assignees)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.taskId,_that.teamId,_that.boardId,_that.title,_that.description,_that.startAt,_that.startHasTime,_that.dueAt,_that.dueHasTime,_that.priority,_that.status,_that.posX,_that.posY,_that.color,_that.size,_that.latestComment,_that.latestCommentBy,_that.latestCommentAt,_that.createdBy,_that.completedAt,_that.completedBy,_that.reviewedAt,_that.returnedAt,_that.deletedAt,_that.createdAt,_that.updatedAt,_that.assignees);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Task extends Task {
  const _Task({required this.taskId, required this.teamId, required this.boardId, required this.title, this.description, this.startAt, this.startHasTime = false, this.dueAt, this.dueHasTime = false, this.priority = TaskPriority.medium, this.status = TaskStatus.todo, this.posX = 0, this.posY = 0, this.color = '#FFF59D', this.size = TaskSize.m, this.latestComment, this.latestCommentBy, this.latestCommentAt, required this.createdBy, this.completedAt, this.completedBy, this.reviewedAt, this.returnedAt, this.deletedAt, this.createdAt, this.updatedAt, @JsonKey(name: 'task_members')  List<TaskAssignee> assignees = const []}): _assignees = assignees,super._();
  factory _Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

@override final  int taskId;
@override final  int teamId;
@override final  int boardId;
@override final  String title;
@override final  String? description;
@override final  DateTime? startAt;
@override@JsonKey() final  bool startHasTime;
@override final  DateTime? dueAt;
@override@JsonKey() final  bool dueHasTime;
@override@JsonKey() final  TaskPriority priority;
@override@JsonKey() final  TaskStatus status;
@override@JsonKey() final  double posX;
@override@JsonKey() final  double posY;
@override@JsonKey() final  String color;
@override@JsonKey() final  TaskSize size;
@override final  String? latestComment;
@override final  String? latestCommentBy;
@override final  DateTime? latestCommentAt;
@override final  String createdBy;
@override final  DateTime? completedAt;
@override final  String? completedBy;
@override final  DateTime? reviewedAt;
@override final  DateTime? returnedAt;
@override final  DateTime? deletedAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
 final  List<TaskAssignee> _assignees;
@override@JsonKey(name: 'task_members') List<TaskAssignee> get assignees {
  if (_assignees is EqualUnmodifiableListView) return _assignees;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignees);
}


/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.boardId, boardId) || other.boardId == boardId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.startHasTime, startHasTime) || other.startHasTime == startHasTime)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.dueHasTime, dueHasTime) || other.dueHasTime == dueHasTime)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.posX, posX) || other.posX == posX)&&(identical(other.posY, posY) || other.posY == posY)&&(identical(other.color, color) || other.color == color)&&(identical(other.size, size) || other.size == size)&&(identical(other.latestComment, latestComment) || other.latestComment == latestComment)&&(identical(other.latestCommentBy, latestCommentBy) || other.latestCommentBy == latestCommentBy)&&(identical(other.latestCommentAt, latestCommentAt) || other.latestCommentAt == latestCommentAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.completedBy, completedBy) || other.completedBy == completedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.returnedAt, returnedAt) || other.returnedAt == returnedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._assignees, _assignees));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,taskId,teamId,boardId,title,description,startAt,startHasTime,dueAt,dueHasTime,priority,status,posX,posY,color,size,latestComment,latestCommentBy,latestCommentAt,createdBy,completedAt,completedBy,reviewedAt,returnedAt,deletedAt,createdAt,updatedAt,const DeepCollectionEquality().hash(_assignees)]);

@override
String toString() {
  return 'Task(taskId: $taskId, teamId: $teamId, boardId: $boardId, title: $title, description: $description, startAt: $startAt, startHasTime: $startHasTime, dueAt: $dueAt, dueHasTime: $dueHasTime, priority: $priority, status: $status, posX: $posX, posY: $posY, color: $color, size: $size, latestComment: $latestComment, latestCommentBy: $latestCommentBy, latestCommentAt: $latestCommentAt, createdBy: $createdBy, completedAt: $completedAt, completedBy: $completedBy, reviewedAt: $reviewedAt, returnedAt: $returnedAt, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt, assignees: $assignees)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 int taskId, int teamId, int boardId, String title, String? description, DateTime? startAt, bool startHasTime, DateTime? dueAt, bool dueHasTime, TaskPriority priority, TaskStatus status, double posX, double posY, String color, TaskSize size, String? latestComment, String? latestCommentBy, DateTime? latestCommentAt, String createdBy, DateTime? completedAt, String? completedBy, DateTime? reviewedAt, DateTime? returnedAt, DateTime? deletedAt, DateTime? createdAt, DateTime? updatedAt,@JsonKey(name: 'task_members') List<TaskAssignee> assignees
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? teamId = null,Object? boardId = null,Object? title = null,Object? description = freezed,Object? startAt = freezed,Object? startHasTime = null,Object? dueAt = freezed,Object? dueHasTime = null,Object? priority = null,Object? status = null,Object? posX = null,Object? posY = null,Object? color = null,Object? size = null,Object? latestComment = freezed,Object? latestCommentBy = freezed,Object? latestCommentAt = freezed,Object? createdBy = null,Object? completedAt = freezed,Object? completedBy = freezed,Object? reviewedAt = freezed,Object? returnedAt = freezed,Object? deletedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? assignees = null,}) {
  return _then(_Task(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,boardId: null == boardId ? _self.boardId : boardId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startHasTime: null == startHasTime ? _self.startHasTime : startHasTime // ignore: cast_nullable_to_non_nullable
as bool,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dueHasTime: null == dueHasTime ? _self.dueHasTime : dueHasTime // ignore: cast_nullable_to_non_nullable
as bool,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,posX: null == posX ? _self.posX : posX // ignore: cast_nullable_to_non_nullable
as double,posY: null == posY ? _self.posY : posY // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as TaskSize,latestComment: freezed == latestComment ? _self.latestComment : latestComment // ignore: cast_nullable_to_non_nullable
as String?,latestCommentBy: freezed == latestCommentBy ? _self.latestCommentBy : latestCommentBy // ignore: cast_nullable_to_non_nullable
as String?,latestCommentAt: freezed == latestCommentAt ? _self.latestCommentAt : latestCommentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedBy: freezed == completedBy ? _self.completedBy : completedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,assignees: null == assignees ? _self._assignees : assignees // ignore: cast_nullable_to_non_nullable
as List<TaskAssignee>,
  ));
}


}


/// @nodoc
mixin _$MyTask {

 int get taskId; int get teamId; String get teamName; int get boardId; String get boardName; String get title; TaskStatus get status; TaskPriority get priority; DateTime? get startAt; bool get startHasTime; DateTime? get dueAt; bool get dueHasTime; String get color; String? get latestComment; DateTime? get returnedAt;
/// Create a copy of MyTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyTaskCopyWith<MyTask> get copyWith => _$MyTaskCopyWithImpl<MyTask>(this as MyTask, _$identity);

  /// Serializes this MyTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyTask&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.teamName, teamName) || other.teamName == teamName)&&(identical(other.boardId, boardId) || other.boardId == boardId)&&(identical(other.boardName, boardName) || other.boardName == boardName)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.startHasTime, startHasTime) || other.startHasTime == startHasTime)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.dueHasTime, dueHasTime) || other.dueHasTime == dueHasTime)&&(identical(other.color, color) || other.color == color)&&(identical(other.latestComment, latestComment) || other.latestComment == latestComment)&&(identical(other.returnedAt, returnedAt) || other.returnedAt == returnedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,teamId,teamName,boardId,boardName,title,status,priority,startAt,startHasTime,dueAt,dueHasTime,color,latestComment,returnedAt);

@override
String toString() {
  return 'MyTask(taskId: $taskId, teamId: $teamId, teamName: $teamName, boardId: $boardId, boardName: $boardName, title: $title, status: $status, priority: $priority, startAt: $startAt, startHasTime: $startHasTime, dueAt: $dueAt, dueHasTime: $dueHasTime, color: $color, latestComment: $latestComment, returnedAt: $returnedAt)';
}


}

/// @nodoc
abstract mixin class $MyTaskCopyWith<$Res>  {
  factory $MyTaskCopyWith(MyTask value, $Res Function(MyTask) _then) = _$MyTaskCopyWithImpl;
@useResult
$Res call({
 int taskId, int teamId, String teamName, int boardId, String boardName, String title, TaskStatus status, TaskPriority priority, DateTime? startAt, bool startHasTime, DateTime? dueAt, bool dueHasTime, String color, String? latestComment, DateTime? returnedAt
});




}
/// @nodoc
class _$MyTaskCopyWithImpl<$Res>
    implements $MyTaskCopyWith<$Res> {
  _$MyTaskCopyWithImpl(this._self, this._then);

  final MyTask _self;
  final $Res Function(MyTask) _then;

/// Create a copy of MyTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,Object? teamId = null,Object? teamName = null,Object? boardId = null,Object? boardName = null,Object? title = null,Object? status = null,Object? priority = null,Object? startAt = freezed,Object? startHasTime = null,Object? dueAt = freezed,Object? dueHasTime = null,Object? color = null,Object? latestComment = freezed,Object? returnedAt = freezed,}) {
  return _then(MyTask(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,teamName: null == teamName ? _self.teamName : teamName // ignore: cast_nullable_to_non_nullable
as String,boardId: null == boardId ? _self.boardId : boardId // ignore: cast_nullable_to_non_nullable
as int,boardName: null == boardName ? _self.boardName : boardName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startHasTime: null == startHasTime ? _self.startHasTime : startHasTime // ignore: cast_nullable_to_non_nullable
as bool,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dueHasTime: null == dueHasTime ? _self.dueHasTime : dueHasTime // ignore: cast_nullable_to_non_nullable
as bool,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,latestComment: freezed == latestComment ? _self.latestComment : latestComment // ignore: cast_nullable_to_non_nullable
as String?,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MyTask].
extension MyTaskPatterns on MyTask {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyTask() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyTask value)  $default,){
final _that = this;
switch (_that) {
case _MyTask():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyTask value)?  $default,){
final _that = this;
switch (_that) {
case _MyTask() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int taskId,  int teamId,  String teamName,  int boardId,  String boardName,  String title,  TaskStatus status,  TaskPriority priority,  DateTime? startAt,  bool startHasTime,  DateTime? dueAt,  bool dueHasTime,  String color,  String? latestComment,  DateTime? returnedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyTask() when $default != null:
return $default(_that.taskId,_that.teamId,_that.teamName,_that.boardId,_that.boardName,_that.title,_that.status,_that.priority,_that.startAt,_that.startHasTime,_that.dueAt,_that.dueHasTime,_that.color,_that.latestComment,_that.returnedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int taskId,  int teamId,  String teamName,  int boardId,  String boardName,  String title,  TaskStatus status,  TaskPriority priority,  DateTime? startAt,  bool startHasTime,  DateTime? dueAt,  bool dueHasTime,  String color,  String? latestComment,  DateTime? returnedAt)  $default,) {final _that = this;
switch (_that) {
case _MyTask():
return $default(_that.taskId,_that.teamId,_that.teamName,_that.boardId,_that.boardName,_that.title,_that.status,_that.priority,_that.startAt,_that.startHasTime,_that.dueAt,_that.dueHasTime,_that.color,_that.latestComment,_that.returnedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int taskId,  int teamId,  String teamName,  int boardId,  String boardName,  String title,  TaskStatus status,  TaskPriority priority,  DateTime? startAt,  bool startHasTime,  DateTime? dueAt,  bool dueHasTime,  String color,  String? latestComment,  DateTime? returnedAt)?  $default,) {final _that = this;
switch (_that) {
case _MyTask() when $default != null:
return $default(_that.taskId,_that.teamId,_that.teamName,_that.boardId,_that.boardName,_that.title,_that.status,_that.priority,_that.startAt,_that.startHasTime,_that.dueAt,_that.dueHasTime,_that.color,_that.latestComment,_that.returnedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyTask implements MyTask {
  const _MyTask({required this.taskId, required this.teamId, required this.teamName, required this.boardId, required this.boardName, required this.title, required this.status, required this.priority, this.startAt, this.startHasTime = false, this.dueAt, this.dueHasTime = false, this.color = '#FFF59D', this.latestComment, this.returnedAt});
  factory _MyTask.fromJson(Map<String, dynamic> json) => _$MyTaskFromJson(json);

@override final  int taskId;
@override final  int teamId;
@override final  String teamName;
@override final  int boardId;
@override final  String boardName;
@override final  String title;
@override final  TaskStatus status;
@override final  TaskPriority priority;
@override final  DateTime? startAt;
@override@JsonKey() final  bool startHasTime;
@override final  DateTime? dueAt;
@override@JsonKey() final  bool dueHasTime;
@override@JsonKey() final  String color;
@override final  String? latestComment;
@override final  DateTime? returnedAt;

/// Create a copy of MyTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyTaskCopyWith<_MyTask> get copyWith => __$MyTaskCopyWithImpl<_MyTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyTask&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.teamName, teamName) || other.teamName == teamName)&&(identical(other.boardId, boardId) || other.boardId == boardId)&&(identical(other.boardName, boardName) || other.boardName == boardName)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.startHasTime, startHasTime) || other.startHasTime == startHasTime)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.dueHasTime, dueHasTime) || other.dueHasTime == dueHasTime)&&(identical(other.color, color) || other.color == color)&&(identical(other.latestComment, latestComment) || other.latestComment == latestComment)&&(identical(other.returnedAt, returnedAt) || other.returnedAt == returnedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,teamId,teamName,boardId,boardName,title,status,priority,startAt,startHasTime,dueAt,dueHasTime,color,latestComment,returnedAt);

@override
String toString() {
  return 'MyTask(taskId: $taskId, teamId: $teamId, teamName: $teamName, boardId: $boardId, boardName: $boardName, title: $title, status: $status, priority: $priority, startAt: $startAt, startHasTime: $startHasTime, dueAt: $dueAt, dueHasTime: $dueHasTime, color: $color, latestComment: $latestComment, returnedAt: $returnedAt)';
}


}

/// @nodoc
abstract mixin class _$MyTaskCopyWith<$Res> implements $MyTaskCopyWith<$Res> {
  factory _$MyTaskCopyWith(_MyTask value, $Res Function(_MyTask) _then) = __$MyTaskCopyWithImpl;
@override @useResult
$Res call({
 int taskId, int teamId, String teamName, int boardId, String boardName, String title, TaskStatus status, TaskPriority priority, DateTime? startAt, bool startHasTime, DateTime? dueAt, bool dueHasTime, String color, String? latestComment, DateTime? returnedAt
});




}
/// @nodoc
class __$MyTaskCopyWithImpl<$Res>
    implements _$MyTaskCopyWith<$Res> {
  __$MyTaskCopyWithImpl(this._self, this._then);

  final _MyTask _self;
  final $Res Function(_MyTask) _then;

/// Create a copy of MyTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? teamId = null,Object? teamName = null,Object? boardId = null,Object? boardName = null,Object? title = null,Object? status = null,Object? priority = null,Object? startAt = freezed,Object? startHasTime = null,Object? dueAt = freezed,Object? dueHasTime = null,Object? color = null,Object? latestComment = freezed,Object? returnedAt = freezed,}) {
  return _then(_MyTask(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int,teamName: null == teamName ? _self.teamName : teamName // ignore: cast_nullable_to_non_nullable
as String,boardId: null == boardId ? _self.boardId : boardId // ignore: cast_nullable_to_non_nullable
as int,boardName: null == boardName ? _self.boardName : boardName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startHasTime: null == startHasTime ? _self.startHasTime : startHasTime // ignore: cast_nullable_to_non_nullable
as bool,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dueHasTime: null == dueHasTime ? _self.dueHasTime : dueHasTime // ignore: cast_nullable_to_non_nullable
as bool,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,latestComment: freezed == latestComment ? _self.latestComment : latestComment // ignore: cast_nullable_to_non_nullable
as String?,returnedAt: freezed == returnedAt ? _self.returnedAt : returnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$StatusHistory {

 int get historyId; int get taskId; String? get userId; TaskStatus get fromStatus; TaskStatus get toStatus; String? get comment; DateTime get createdAt;
/// Create a copy of StatusHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusHistoryCopyWith<StatusHistory> get copyWith => _$StatusHistoryCopyWithImpl<StatusHistory>(this as StatusHistory, _$identity);

  /// Serializes this StatusHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusHistory&&(identical(other.historyId, historyId) || other.historyId == historyId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,historyId,taskId,userId,fromStatus,toStatus,comment,createdAt);

@override
String toString() {
  return 'StatusHistory(historyId: $historyId, taskId: $taskId, userId: $userId, fromStatus: $fromStatus, toStatus: $toStatus, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $StatusHistoryCopyWith<$Res>  {
  factory $StatusHistoryCopyWith(StatusHistory value, $Res Function(StatusHistory) _then) = _$StatusHistoryCopyWithImpl;
@useResult
$Res call({
 int historyId, int taskId, String? userId, TaskStatus fromStatus, TaskStatus toStatus, String? comment, DateTime createdAt
});




}
/// @nodoc
class _$StatusHistoryCopyWithImpl<$Res>
    implements $StatusHistoryCopyWith<$Res> {
  _$StatusHistoryCopyWithImpl(this._self, this._then);

  final StatusHistory _self;
  final $Res Function(StatusHistory) _then;

/// Create a copy of StatusHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? historyId = null,Object? taskId = null,Object? userId = freezed,Object? fromStatus = null,Object? toStatus = null,Object? comment = freezed,Object? createdAt = null,}) {
  return _then(StatusHistory(
historyId: null == historyId ? _self.historyId : historyId // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,fromStatus: null == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as TaskStatus,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as TaskStatus,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusHistory].
extension StatusHistoryPatterns on StatusHistory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusHistory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusHistory value)  $default,){
final _that = this;
switch (_that) {
case _StatusHistory():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusHistory value)?  $default,){
final _that = this;
switch (_that) {
case _StatusHistory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int historyId,  int taskId,  String? userId,  TaskStatus fromStatus,  TaskStatus toStatus,  String? comment,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusHistory() when $default != null:
return $default(_that.historyId,_that.taskId,_that.userId,_that.fromStatus,_that.toStatus,_that.comment,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int historyId,  int taskId,  String? userId,  TaskStatus fromStatus,  TaskStatus toStatus,  String? comment,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _StatusHistory():
return $default(_that.historyId,_that.taskId,_that.userId,_that.fromStatus,_that.toStatus,_that.comment,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int historyId,  int taskId,  String? userId,  TaskStatus fromStatus,  TaskStatus toStatus,  String? comment,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _StatusHistory() when $default != null:
return $default(_that.historyId,_that.taskId,_that.userId,_that.fromStatus,_that.toStatus,_that.comment,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatusHistory implements StatusHistory {
  const _StatusHistory({required this.historyId, required this.taskId, this.userId, required this.fromStatus, required this.toStatus, this.comment, required this.createdAt});
  factory _StatusHistory.fromJson(Map<String, dynamic> json) => _$StatusHistoryFromJson(json);

@override final  int historyId;
@override final  int taskId;
@override final  String? userId;
@override final  TaskStatus fromStatus;
@override final  TaskStatus toStatus;
@override final  String? comment;
@override final  DateTime createdAt;

/// Create a copy of StatusHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusHistoryCopyWith<_StatusHistory> get copyWith => __$StatusHistoryCopyWithImpl<_StatusHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusHistory&&(identical(other.historyId, historyId) || other.historyId == historyId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,historyId,taskId,userId,fromStatus,toStatus,comment,createdAt);

@override
String toString() {
  return 'StatusHistory(historyId: $historyId, taskId: $taskId, userId: $userId, fromStatus: $fromStatus, toStatus: $toStatus, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$StatusHistoryCopyWith<$Res> implements $StatusHistoryCopyWith<$Res> {
  factory _$StatusHistoryCopyWith(_StatusHistory value, $Res Function(_StatusHistory) _then) = __$StatusHistoryCopyWithImpl;
@override @useResult
$Res call({
 int historyId, int taskId, String? userId, TaskStatus fromStatus, TaskStatus toStatus, String? comment, DateTime createdAt
});




}
/// @nodoc
class __$StatusHistoryCopyWithImpl<$Res>
    implements _$StatusHistoryCopyWith<$Res> {
  __$StatusHistoryCopyWithImpl(this._self, this._then);

  final _StatusHistory _self;
  final $Res Function(_StatusHistory) _then;

/// Create a copy of StatusHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? historyId = null,Object? taskId = null,Object? userId = freezed,Object? fromStatus = null,Object? toStatus = null,Object? comment = freezed,Object? createdAt = null,}) {
  return _then(_StatusHistory(
historyId: null == historyId ? _self.historyId : historyId // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,fromStatus: null == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as TaskStatus,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as TaskStatus,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$AppNotification {

 int get notificationId; String get recipientUserId; String? get actorUserId; int? get teamId; int? get taskId; NotificationType get type; String get message; bool get isRead; DateTime get createdAt;
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<AppNotification> get copyWith => _$AppNotificationCopyWithImpl<AppNotification>(this as AppNotification, _$identity);

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotification&&(identical(other.notificationId, notificationId) || other.notificationId == notificationId)&&(identical(other.recipientUserId, recipientUserId) || other.recipientUserId == recipientUserId)&&(identical(other.actorUserId, actorUserId) || other.actorUserId == actorUserId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notificationId,recipientUserId,actorUserId,teamId,taskId,type,message,isRead,createdAt);

@override
String toString() {
  return 'AppNotification(notificationId: $notificationId, recipientUserId: $recipientUserId, actorUserId: $actorUserId, teamId: $teamId, taskId: $taskId, type: $type, message: $message, isRead: $isRead, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AppNotificationCopyWith<$Res>  {
  factory $AppNotificationCopyWith(AppNotification value, $Res Function(AppNotification) _then) = _$AppNotificationCopyWithImpl;
@useResult
$Res call({
 int notificationId, String recipientUserId, String? actorUserId, int? teamId, int? taskId, NotificationType type, String message, bool isRead, DateTime createdAt
});




}
/// @nodoc
class _$AppNotificationCopyWithImpl<$Res>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._self, this._then);

  final AppNotification _self;
  final $Res Function(AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notificationId = null,Object? recipientUserId = null,Object? actorUserId = freezed,Object? teamId = freezed,Object? taskId = freezed,Object? type = null,Object? message = null,Object? isRead = null,Object? createdAt = null,}) {
  return _then(AppNotification(
notificationId: null == notificationId ? _self.notificationId : notificationId // ignore: cast_nullable_to_non_nullable
as int,recipientUserId: null == recipientUserId ? _self.recipientUserId : recipientUserId // ignore: cast_nullable_to_non_nullable
as String,actorUserId: freezed == actorUserId ? _self.actorUserId : actorUserId // ignore: cast_nullable_to_non_nullable
as String?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppNotification].
extension AppNotificationPatterns on AppNotification {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppNotification value)  $default,){
final _that = this;
switch (_that) {
case _AppNotification():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppNotification value)?  $default,){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int notificationId,  String recipientUserId,  String? actorUserId,  int? teamId,  int? taskId,  NotificationType type,  String message,  bool isRead,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.notificationId,_that.recipientUserId,_that.actorUserId,_that.teamId,_that.taskId,_that.type,_that.message,_that.isRead,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int notificationId,  String recipientUserId,  String? actorUserId,  int? teamId,  int? taskId,  NotificationType type,  String message,  bool isRead,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AppNotification():
return $default(_that.notificationId,_that.recipientUserId,_that.actorUserId,_that.teamId,_that.taskId,_that.type,_that.message,_that.isRead,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int notificationId,  String recipientUserId,  String? actorUserId,  int? teamId,  int? taskId,  NotificationType type,  String message,  bool isRead,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.notificationId,_that.recipientUserId,_that.actorUserId,_that.teamId,_that.taskId,_that.type,_that.message,_that.isRead,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppNotification implements AppNotification {
  const _AppNotification({required this.notificationId, required this.recipientUserId, this.actorUserId, this.teamId, this.taskId, required this.type, required this.message, this.isRead = false, required this.createdAt});
  factory _AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

@override final  int notificationId;
@override final  String recipientUserId;
@override final  String? actorUserId;
@override final  int? teamId;
@override final  int? taskId;
@override final  NotificationType type;
@override final  String message;
@override@JsonKey() final  bool isRead;
@override final  DateTime createdAt;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotificationCopyWith<_AppNotification> get copyWith => __$AppNotificationCopyWithImpl<_AppNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotification&&(identical(other.notificationId, notificationId) || other.notificationId == notificationId)&&(identical(other.recipientUserId, recipientUserId) || other.recipientUserId == recipientUserId)&&(identical(other.actorUserId, actorUserId) || other.actorUserId == actorUserId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notificationId,recipientUserId,actorUserId,teamId,taskId,type,message,isRead,createdAt);

@override
String toString() {
  return 'AppNotification(notificationId: $notificationId, recipientUserId: $recipientUserId, actorUserId: $actorUserId, teamId: $teamId, taskId: $taskId, type: $type, message: $message, isRead: $isRead, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AppNotificationCopyWith<$Res> implements $AppNotificationCopyWith<$Res> {
  factory _$AppNotificationCopyWith(_AppNotification value, $Res Function(_AppNotification) _then) = __$AppNotificationCopyWithImpl;
@override @useResult
$Res call({
 int notificationId, String recipientUserId, String? actorUserId, int? teamId, int? taskId, NotificationType type, String message, bool isRead, DateTime createdAt
});




}
/// @nodoc
class __$AppNotificationCopyWithImpl<$Res>
    implements _$AppNotificationCopyWith<$Res> {
  __$AppNotificationCopyWithImpl(this._self, this._then);

  final _AppNotification _self;
  final $Res Function(_AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notificationId = null,Object? recipientUserId = null,Object? actorUserId = freezed,Object? teamId = freezed,Object? taskId = freezed,Object? type = null,Object? message = null,Object? isRead = null,Object? createdAt = null,}) {
  return _then(_AppNotification(
notificationId: null == notificationId ? _self.notificationId : notificationId // ignore: cast_nullable_to_non_nullable
as int,recipientUserId: null == recipientUserId ? _self.recipientUserId : recipientUserId // ignore: cast_nullable_to_non_nullable
as String,actorUserId: freezed == actorUserId ? _self.actorUserId : actorUserId // ignore: cast_nullable_to_non_nullable
as String?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as int?,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
