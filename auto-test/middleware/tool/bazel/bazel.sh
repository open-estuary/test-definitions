#!/bin/bash

set -x

cd ../../../../utils
   source  ./sys_info.sh
   source  ./sh-test-lib
cd -

yum remove java* -y

case "${distro}" in
	centos)
		pkgs="gcc java-1.8.0-openjdk java-1.8.0-openjdk-devel bazel"
		install_deps "${pkgs}"
		print_info $? install-bazel
	        ;;
	     *)
		error_msg "Unsupported distribution!"
esac

dir="my-project"
mkdir $dir
cd $dir
mkdir -p src/main/java/com/example
touch WORKSPACE
print_info $? setup-WORKSPACE

cat > src/main/java/com/example/ProjectRunner.java <<EOF
package com.example;

public class ProjectRunner {
	public static void main(String args[]) {
        Greeting.sayHi();
	}
}
EOF

cat > src/main/java/com/example/Greeting.java <<EOF
package com.example;

public class Greeting {
	public static void sayHi() {
        System.out.println("Hi!");
	}
}
EOF
print_info $? setup-simple-java

cat > BUILD <<EOF
java_binary(
    name = "my-runner",
    srcs = glob(["**/*.java"]),
    main_class = "com.example.ProjectRunner",

)
EOF
print_info $? setup-simple-BUILD

bazel build //:my-runner
print_info $? build-simple-java

bazel-bin/my-runner
print_info $? run-simple-java

cat > BUILD <<EOF
java_binary(
    name = "my-other-runner",
	srcs = ["src/main/java/com/example/ProjectRunner.java"],
	main_class = "com.example.ProjectRunner",
	deps = [":greeter"],
)

java_library(
    name = "greeter",
	srcs = ["src/main/java/com/example/Greeting.java"],
)
EOF
print_info $? setup-related-BUILD

bazel run //:my-other-runner
print_info $? run-related-java

mkdir -p src/main/java/com/example/cmdline
cat > src/main/java/com/example/cmdline/Runner.java <<EOF
package com.example.cmdline;

import com.example.Greeting;

public class Runner {
	public static void main(String args[]) {
        Greeting.sayHi();
	}
}
EOF
print_info $? setup-package-java

cat > src/main/java/com/example/cmdline/BUILD <<EOF
java_binary(
    name = "runner",
	srcs = ["Runner.java"],
	main_class = "com.example.cmdline.Runner",
	deps = ["//:greeter"]
)
EOF
print_info $? setup-package-BUILD

bazel build //src/main/java/com/example/cmdline:runner
if [ $? ];then
	print_info 0 run-package-ERROR
else
	print_info 1 run-package-ERROR
fi

#sed -i '/example/Greeting.java/a\    visibility = ["//src/main/java/com/example/cmdline:__pkg__"],' BUILD
cat > ./BUILD <<EOF
java_binary(
    name = "my-other-runner",
	srcs = ["src/main/java/com/example/ProjectRunner.java"],
	main_class = "com.example.ProjectRunner",
	deps = [":greeter"],

)

java_library(
    name = "greeter",
	srcs = ["src/main/java/com/example/Greeting.java"],
	visibility = ["//src/main/java/com/example/cmdline:__pkg__"],
)
EOF
print_info $? resetup-package-BUILD

bazel run //src/main/java/com/example/cmdline:runner
print_info $? rerun-package-java

jar tf bazel-bin/src/main/java/com/example/cmdline/runner.jar
print_info $? look-package-runner

bazel build //src/main/java/com/example/cmdline:runner_deploy.jar
print_info $? build-allpackage-runner

remove_deps "${pkgs}" 
 if test $? -eq 0;then
    print_info 0 remove
 else
    print_info 1 remove
 fi 

