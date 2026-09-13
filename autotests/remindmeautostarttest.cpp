/*
    SPDX-FileCopyrightText: 2026 David Laws

    SPDX-License-Identifier: GPL-3.0-or-later
*/

#include "remindmeautostart.h"

#include <KConfigGroup>
#include <KDesktopFile>

#include <QCoreApplication>
#include <QFile>
#include <QObject>
#include <QTemporaryDir>
#include <QTest>

class RemindmeAutostartTest : public QObject
{
    Q_OBJECT

private:
    QScopedPointer<QTemporaryDir> tempDir;

    QString entryPath() const
    {
        return tempDir->path() + QStringLiteral("/krunner-remindme.desktop");
    }

    bool hidden(bool defaultHidden) const
    {
        KDesktopFile file(entryPath());
        return file.desktopGroup().readEntry("Hidden", defaultHidden);
    }

private Q_SLOTS:
    void init()
    {
        tempDir.reset(new QTemporaryDir);
        QVERIFY(tempDir->isValid());
    }

    void cleanup()
    {
        tempDir.reset();
    }

    void testEnableWritesRunnableEntry()
    {
        RemindmeAutostart autostart(tempDir->path());
        autostart.setActive(true);

        QVERIFY(QFile::exists(entryPath()));
        QCOMPARE(hidden(true), false); // enabled
        KDesktopFile file(entryPath());
        QCOMPARE(file.desktopGroup().readEntry("Type"), QStringLiteral("Application"));
        QVERIFY(!file.desktopGroup().readEntry("Exec").isEmpty());
    }

    void testDisableHidesEntry()
    {
        RemindmeAutostart autostart(tempDir->path());
        autostart.setActive(true);
        autostart.setActive(false);

        QVERIFY(hidden(false)); // disabled
        // The entry is retained (Hidden=true) so it can be re-enabled without recreating it.
        QVERIFY(QFile::exists(entryPath()));
    }

    void testReenableAfterDisable()
    {
        RemindmeAutostart autostart(tempDir->path());
        autostart.setActive(true);
        autostart.setActive(false);
        autostart.setActive(true);

        QCOMPARE(hidden(true), false); // enabled again
    }
};

QTEST_GUILESS_MAIN(RemindmeAutostartTest)

#include "remindmeautostarttest.moc"
