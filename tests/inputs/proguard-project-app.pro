# https://raw.githubusercontent.com/krschultz/android-proguard-snippets/master/examples/proguard-project-app.pro
# The simpliest strategy is to not run proguard against your project's own code.
# This doesn't provide the benefits of optimization & obfuscation against your 
# project, but will still strip the libraries. The advantage is that your app will
# work without any subsequent effort. If you choose this strategy, the proguard
# configuration for the project is simply the line below.

-keep class com.yourpackage.app.** { *; }

# The more involved strategy is to specifically provide rules to keep portions of your
# app's codebase unmodified while allowing proguard to optimize the rest. 

# The first decision is whether or not you want to obfuscate your code. This provides no
# performance benefit but makes it harder for other people to read your source code. 
# Unfortunately obfuscation can cause issues for code that uses reflection or a few other
# techniques. The default is to obfuscate.

-dontobfuscate

# Additionally you will need to keep specific classes. A common use case is keeping all
# of the models that are JSON parsed using something like Jackson.

-keep class com.yourpackage.app.model.User { *; }

