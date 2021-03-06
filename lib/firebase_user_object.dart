import 'package:cloud_firestore/cloud_firestore.dart';

class UserObj {
  final String? name;
  final String? email;
  final String? bio;
  final String? photoUrl;
  final List<String>? majors;
  final List<String>? hobbies;
  final List<String>? classes; // list of class ids
  final Map<String, String>? socials; // maps social media website (insta, FB, and SC) to their profile links
  // Friends will be stored in firebase subcollection with friend objects showing which class friend is from

  UserObj({
    this.name,
    this.email,
    this.bio,
    this.photoUrl,
    this.majors,
    this.hobbies,
    this.classes,
    this.socials
  });

  UserObj.simple(this.name, this.email, this.photoUrl) : bio = null, majors = null,
                hobbies = null, classes = null, socials = null {}

  factory UserObj.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return UserObj(
      name: data?['name'],
      email: data?['email'],
      bio: data?['bio'],
      photoUrl: data?['photoUrl'],
      majors: data?['majors'] is Iterable ? List.from(data?['majors']) : null,
      hobbies: data?['hobbies'] is Iterable ? List.from(data?['hobbies']) : null,
      classes: data?['classes'] is Iterable ? List.from(data?['classes']) : null,
      socials: data?['socials'] is Iterable ? Map<String, String>.from(data?['socials']) : null
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
      "bio": bio,
      "photoUrl": photoUrl,
      "majors": majors,
      "hobbies": hobbies,
      "classes": classes,
      "socials": socials
    };
  }
}