/*
    SPDX-FileCopyrightText: 2026 David Laws

    SPDX-License-Identifier: GPL-3.0-or-later
*/

#include "remindmeautostart.h"

#include <KConfigGroup>
#include <KDesktopFile>

#include <QCoreApplication>
#include <QDir>
#include <QStandardPaths>

namespace
{
const QString s_entryName{QStringLiteral("krunner-remindme.desktop")};
}

RemindmeAutostart::RemindmeAutostart(QString autostartDir)
    : m_autostartDir(std::move(autostartDir))
{
    if (m_autostartDir.isEmpty()) {
        m_autostartDir = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation) + QStringLiteral("/autostart");
    }
    m_entryPath = m_autostartDir + QLatin1Char('/') + s_entryName;
}

RemindmeAutostart::~RemindmeAutostart() = default;

void RemindmeAutostart::setActive(bool active)
{
    QDir().mkpath(m_autostartDir);

    KDesktopFile file(m_entryPath);
    KConfigGroup group = file.desktopGroup();
    group.writeEntry("Type", QStringLiteral("Application"));
    group.writeEntry("Name", QStringLiteral("RemindMe Timer"));
    group.writeEntry("Exec", QStringLiteral("'%1'").arg(QCoreApplication::applicationFilePath()));
    group.writeEntry("Terminal", false);
    group.writeEntry("Hidden", !active);
    file.sync();
}
