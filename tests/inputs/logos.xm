# https://github.com/theos/logos#source-file-tweakx 
# c++
%hook NSObject

- (NSString *)description {
	return [%orig stringByAppendingString:@" (of doom)"];
}

%new - (void)helloWorld {
	NSLog(@"Awesome!");
}

%end
