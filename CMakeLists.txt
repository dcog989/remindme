# SPDX-FileCopyrightText: 2026 David Laws
# SPDX-License-Identifier: GPL-3.0-or-later
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

find_package(Qt6 6.9 REQUIRED COMPONENTS Core DBus Widgets Test)
# Runner is needed by the integration test (AbstractRunnerTest / RunnerManager); the installed
# runner itself does not link it.
find_package(KF6 6.9 REQUIRED COMPONENTS CoreAddons I18n Notifications Config Runner)

add_subdirectory(src)

if(BUILD_TESTING)
    add_subdirectory(autotests)
endif()

feature_summary(WHAT ALL)
