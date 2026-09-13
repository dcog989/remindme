#pragma once

#include <QString>

namespace Remindme
{
constexpr int maxDurationSeconds = 99 * 3600 + 59 * 60 + 59;

struct Duration {
    int seconds = 0;
    QString message;
    bool valid = false;
};

Duration parseDurationAndMessage(const QString &input);
}
