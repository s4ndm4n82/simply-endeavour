/**********************************************************************
*                                                                     *
*                      SDDM Theme for Endeavour OS                    *
*                                                                     *
*       Created by: S4NDM4N                      Version: 1.0         *
*                                                                     *
**********************************************************************/

// Library impors.
import QtQuick 2.14
import QtQuick.Controls 2.14
import SddmComponents 2.0
import "ControlSet" as Cset


Rectangle{
    readonly property color backgroundColor: Qt.rgba(0, 0, 0, 0.4)
    readonly property color hoverBackgroundColor: Qt.rgba(0, 0, 0, 0.6)

    width: 640
    height: 480

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    TextConstants { id: textConstants }

    Connections {  
        target: sddm

        onLoginSucceeded: {}

        onLoginFailed: {
            passEntry.clear()
            passEntry.focus = true

            errorMsgContainer.visible = true
        }
    }

    Background {
        anchors.fill: parent
        source: config.background        
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
            }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Cset.ComboBox {
            id: userName
            model: userModel
            currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
            textRole: "realName"
            width: 250
            KeyNavigation.backtab: session
            KeyNavigation.tab: passEntry
        }

        TextField {
            id: passEntry
            color: "White"
            echoMode: TextInput.Password
            focus: true
            placeholderText: textConstants.promptPassword
            width: 250
            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 30
                color: passEntry.activeFocus ? hoverBackgroundColor : backgroundColor
                border.color: Qt.rgba(1,1,1,0.4)
                radius: 3
            }
            onAccepted: sddm.login(userName.getValue(), passEntry.text, session.currentIndex)
            KeyNavigation.backtab: userName
            KeyNavigation.tab: loginButton
        }

        Cset.Button {
            id: loginButton
            text: textConstants.login
            width: 250
            onClicked: sddm.login(userName.getValue(), passEntry.text, session.currentIndex)
            KeyNavigation.backtab: passEntry
            KeyNavigation.tab: suspendButton
        }

        Rectangle {
            id: errMsgBox
            width: 250
            height: loginButton.height
            color: "#F44336"
            clip: true
            visible: false
            radius: 3

            Label {                
                anchors.centerIn: parent
                text: textConstants.loginFailed
                width: 240
                color: "white"
                font.bold: true
                elide: Qt.locale().textDirection == Qt.RightToLeft ? Text.ElideLeft : Text.ElideRight
                horizontalAlignment: Qt.AlignHCenter                
            }
        }
    }

    Row {        
        anchors {
            bottom: parent.bottom
            bottomMargin: 10            
            horizontalCenter: parent.horizontalCenter
        }

        spacing: 5

        ImageButton {
            id: suspendButton
            source: config.suspend            
            onClicked: sddm.suspend()
            //visible: sddm.canSuspend
            KeyNavigation.backtab: loginButton
            KeyNavigation.tab: hibernate
        }

        ImageButton {
            id: hibernateButton
            source: config.hibernate
            onClicked: sddm.hibernate()
            //visible: sddm.canHibernate
            KeyNavigation.backtab: suspendButton
            KeyNavigation.tab: restartButton
        }

        ImageButton {
            id: restartButton
            source: config.restart
            onClicked: sddm.reboot()
            //visible: sddm.canReboot
            KeyNavigation.backtab: suspendButton
            KeyNavigation.tab: shutdownButton
        }

        ImageButton {
            id: shutdownButton
            source: config.shutdown            
            onClicked: sddm.powerOff()
            //visible: sddm.canPowerOff
            KeyNavigation.backtab: restartButton
            KeyNavigation.tab: session
        }

    }

    Cset.ComboBox {
        id: session
        anchors {
            left: parent.left
            leftMargin: 10
            top: parent.top
            topMargin: 10
        }
        currentIndex: sessionModel.lastIndex
        model: sessionModel
        textRole: "name"
        width: 200
        visible: sessionModel.rowCount() > 1
        KeyNavigation.backtab: shutdownButton
        KeyNavigation.tab: userName
    }

    Rectangle {
        id: clockBox
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 10
            rightMargin: 10
        }
        border.color: Qt(1,1,1,0.4)
        radius: 3
        color: backgroundColor
        width: timelbl.width + 10
        height: session.height

        Label {
            id: timelbl
            anchors.centerIn: parent
            text: Qt.formatDateTime(new Date(), "HH:mm")            
            horizontalAlignment: Text.AlignHCenter

            color: "white"
            font.pixelSize: 15            
        }
    }

    Timer {
        id: timetr
        interval: 500
        repeat: true
        onTriggered: {
            timelb.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    Component.onCompleted: print(sddm.canPowerOff)
}
