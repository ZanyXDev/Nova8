import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15 as QQC2

import common 1.0
import pages 1.0
import io.github.zanyxdev.nova8 1.0
import io.github.zanyxdev.nova8.hal 1.0

QQC2.ApplicationWindow {
  id: appWnd

  // ----- Property Declarations
  // Required properties should be at the top.
  readonly property int screenOrientation: Qt.PortraitOrientation
  readonly property bool appInForeground: Qt.application.state === Qt.ApplicationActive
  property var screenWidth: Screen.width
  property var screenHeight: Screen.height
  property var screenAvailableWidth: Screen.desktopAvailableWidth
  property var screenAvailableHeight: Screen.desktopAvailableHeight
  // ----- Signal declarations

  // ----- Size information
  width: (screenOrientation === Qt.PortraitOrientation) ? 360 : 640
  height: (screenOrientation === Qt.PortraitOrientation) ? 640 : 360
  maximumHeight: height
  maximumWidth: width

  minimumHeight: height
  minimumWidth: width

  // ----- Then comes the other properties. There's no predefined order to these.
  visible: true
  visibility: (isMobile) ? Window.FullScreen : Window.Windowed
  flags: Qt.Dialog

  title: (isMobile) ? qsTr(" ") : Qt.application.name
  onAppInForegroundChanged: {
    AppSingleton.toLog(`appInForeground: [${appInForeground}] Qt.application.version ${Qt.application.version}`)
    if (appInForeground) {

      //paused
    } else {

      //played
    }
  }

  // ----- Signal handlers
  // ----- Qt provided visual children

  // ----- Qt provided non-visual children

  // ----- Custom non-visual children
  Component.onCompleted: {
    if (!isMobile) {
      appWnd.moveToCenter()
    }
  }

  // ----- JavaScript functions
  function moveToCenter() {
    appWnd.y = (screenAvailableHeight / 2) - (height / 2)
    appWnd.x = (screenAvailableWidth / 2) - (width / 2)
  }
  function bellAnimationFinished() {
    console.log("bellAnimationFinished()")
  }
}
