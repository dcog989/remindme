cmake_minimum_required(VERSION 3.29)

project(remindme VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(ECM 6.9 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMGenerateDBusServiceFile)
include(ECMAddTests)
include(FeatureSummary)

find_package(Qt6 6.9 REQUIRED COMPONENTS Core DBus Widgets)
find_package(KF6 6.9 REQUIRED COMPONENTS CoreAddons I18n Notifications Config)

add_subdirectory(src)

if(BUILD_TESTING)
    # Tests only; the installed runner does not link them.
    # Qt6::Test for the unit tests; KF6::Runner for AbstractRunnerTest/RunnerManager.
    find_package(Qt6 6.9 REQUIRED COMPONENTS Test)
    find_package(KF6 6.9 REQUIRED COMPONENTS Runner)
    add_subdirectory(autotests)
endif()

feature_summary(WHAT ALL)
