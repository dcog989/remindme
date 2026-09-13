
set(REMINDME_ENGINE_DIR ${CMAKE_SOURCE_DIR}/src/engine)

ecm_add_test(remindmetimetest.cpp TEST_NAME remindmetimetest LINK_LIBRARIES Qt6::Test)
target_sources(remindmetimetest PRIVATE ${REMINDME_ENGINE_DIR}/remindmetime.cpp)
target_include_directories(remindmetimetest PRIVATE ${REMINDME_ENGINE_DIR})

ecm_add_test(remindmeenginetest.cpp TEST_NAME remindmeenginetest LINK_LIBRARIES Qt6::Test)
target_sources(remindmeenginetest PRIVATE ${REMINDME_ENGINE_DIR}/remindmeengine.cpp)
target_include_directories(remindmeenginetest PRIVATE ${REMINDME_ENGINE_DIR})

ecm_add_test(remindmeautostarttest.cpp TEST_NAME remindmeautostarttest LINK_LIBRARIES Qt6::Test KF6::ConfigCore)
target_sources(remindmeautostarttest PRIVATE ${REMINDME_ENGINE_DIR}/remindmeautostart.cpp)
target_include_directories(remindmeautostarttest PRIVATE ${REMINDME_ENGINE_DIR})

# The runner is a DBus runner, exercised end to end via AbstractRunnerTest against a real
# subprocess on a private session bus (krunner_configure_test picks the DBus branch because
# krunner-remindme is an executable).
ecm_add_test(remindmeintegrationtest.cpp TEST_NAME remindmeintegrationtest LINK_LIBRARIES Qt6::Test Qt6::DBus KF6::Runner)
krunner_configure_test(remindmeintegrationtest krunner-remindme
    DESKTOP_FILE ${CMAKE_SOURCE_DIR}/data/plasma-runner-remindme.desktop
)
