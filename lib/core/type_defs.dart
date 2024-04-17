// the goal of this type defintion is to make exception handling easier, we're gonna use this on
//googleSignIn function as a return type, to have it return the left type (Failure) in case of an error,
//or the right type (generic) in case of success

import 'package:fpdart/fpdart.dart';
import 'package:uni_course/core/failure.dart';

//T means a generic, so it can be of any type.
typedef FutureEither<T> = Future<Either<Failure, T>>;
//refer to signInWithGoogle function to see implementation

//this means it can be either Failure, or void
typedef FutureVoid = FutureEither<void>;
