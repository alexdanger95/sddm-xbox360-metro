import QtQuick
import QtQuick.Controls
import QtMultimedia
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property string errorText: ""
    property bool sessionMenuOpen: false
    property string pendingAction: ""

    SoundEffect { id: soundBotoes; source: "file:///usr/share/sddm/themes/xbox360-metro/sounds/botoes.wav"; volume: 0.8 }
    SoundEffect { id: soundDesligar; source: "file:///usr/share/sddm/themes/xbox360-metro/sounds/desligar.wav"; volume: 0.9 }
    SoundEffect { id: soundEntrar; source: "file:///usr/share/sddm/themes/xbox360-metro/sounds/entrar.wav"; volume: 0.9 }
    SoundEffect { id: soundErro; source: "file:///usr/share/sddm/themes/xbox360-metro/sounds/erro.wav"; volume: 0.9 }
    SoundEffect { id: soundIniciar; source: "file:///usr/share/sddm/themes/xbox360-metro/sounds/iniciar.wav"; volume: 0.9 }
    SoundEffect { id: soundMenu; source: "file:///usr/share/sddm/themes/xbox360-metro/sounds/menu.wav"; volume: 0.85 }
    SoundEffect { id: soundReiniciar; source: "file:///usr/share/sddm/themes/xbox360-metro/sounds/reiniciar.wav"; volume: 0.9 }

    Component.onCompleted: { startTimer.start(); introAnim.start() }
    Timer { id: startTimer; interval: 350; repeat: false; onTriggered: soundIniciar.play() }

    ParallelAnimation {
        id: introAnim
        NumberAnimation { target: headerBar; property: "opacity"; from: 0.0; to: 1.0; duration: 1000; easing.type: Easing.OutQuad }
        NumberAnimation { target: bottomBar; property: "opacity"; from: 0.0; to: 1.0; duration: 1000; easing.type: Easing.OutQuad }
        NumberAnimation { target: centerTiles; property: "opacity"; from: 0.0; to: 1.0; duration: 1000; easing.type: Easing.OutCubic }
        NumberAnimation { target: centerTiles; property: "anchors.verticalCenterOffset"; from: 90; to: 0; duration: 1000; easing.type: Easing.OutCubic }
    }

    Timer {
        id: actionTimer; interval: 650; repeat: false
        onTriggered: {
            if (root.pendingAction === "reboot") sddm.reboot()
            else if (root.pendingAction === "poweroff") sddm.powerOff()
            else if (root.pendingAction === "login") {
                var userName = userModel.data(userModel.index(root.userIndex, 0), Qt.UserRole + 1)
                sddm.login(userName, passwordInput.text, root.sessionIndex)
            }
        }
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_F10) {
            soundReiniciar.play(); root.pendingAction = "reboot"; actionTimer.start(); event.accepted = true
        } else if (event.key === Qt.Key_F12) {
            soundDesligar.play(); root.pendingAction = "poweroff"; actionTimer.start(); event.accepted = true
        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
            soundMenu.play(); root.sessionMenuOpen = true
            root.sessionIndex = (root.sessionIndex + 1) % sessionModel.count; event.accepted = true
        } else if (event.key === Qt.Key_PageUp && userModel.count > 1) {
            soundBotoes.stop(); soundBotoes.play()
            root.userIndex = (root.userIndex - 1 + userModel.count) % userModel.count; event.accepted = true
        } else if (event.key === Qt.Key_PageDown && userModel.count > 1) {
            soundBotoes.stop(); soundBotoes.play()
            root.userIndex = (root.userIndex + 1) % userModel.count; event.accepted = true
        }
    }

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#F2F4F7" }
        GradientStop { position: 0.65; color: "#D5D9DF" }
        GradientStop { position: 1.0; color: "#AEB5BE" }
    }

    Rectangle { anchors.top: parent.top; width: parent.width; height: 6; color: "#52B043" }

    Item {
        id: headerBar; opacity: 0.0
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 48; height: 60
        Row {
            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 14
            Image { width: 44; height: 44; source: "file:///usr/share/sddm/themes/xbox360-metro/xbox_logo.png"; fillMode: Image.PreserveAspectFit; smooth: true }
            Text { text: "XBOX 360"; font.pixelSize: 26; font.bold: true; font.letterSpacing: 2; color: "#3A3F45"; anchors.verticalCenter: parent.verticalCenter }
        }
        Text {
            id: clockText; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; font.pixelSize: 26; font.bold: true; color: "#3A3F45"
            text: Qt.formatTime(new Date(), "HH:mm")
            Timer { interval: 1000; running: true; repeat: true; onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm") }
        }
    }
    Row {
        id: centerTiles; opacity: 0.0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 90
        spacing: 22; z: 10
        Rectangle {
            width: 300; height: 340; color: "#FFFFFF"; border.color: "#52B043"; border.width: 4
            Column {
                anchors.fill: parent; anchors.margins: 24; spacing: 18
                Text { text: "ENTRAR NO PERFIL"; font.pixelSize: 14; font.bold: true; font.letterSpacing: 1.5; color: "#52B043" }
                Rectangle {
                    width: 150; height: 150; anchors.horizontalCenter: parent.horizontalCenter; color: "#26292E"; border.color: "#26292E"; border.width: 4
                    Image { id: avatarImg; anchors.fill: parent; anchors.margins: 4; fillMode: Image.PreserveAspectCrop; source: userModel.data(userModel.index(root.userIndex, 0), Qt.UserRole + 4) || "" }
                    Text { visible: avatarImg.status !== Image.Ready; anchors.centerIn: parent; text: "☺"; font.pixelSize: 72; color: "#52B043" }
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter; spacing: 12
                    Text {
                        text: "◀"; font.pixelSize: 20; color: prevUserMouse.containsMouse ? "#38802C" : "#52B043"; visible: userModel.count > 1
                        MouseArea { id: prevUserMouse; anchors.fill: parent; hoverEnabled: true; onEntered: { soundBotoes.stop(); soundBotoes.play() } onClicked: root.userIndex = (root.userIndex - 1 + userModel.count) % userModel.count }
                    }
                    Text { text: userModel.data(userModel.index(root.userIndex, 0), Qt.UserRole + 1) || "Jogador 1"; font.pixelSize: 22; font.bold: true; color: "#22252A" }
                    Text {
                        text: "▶"; font.pixelSize: 20; color: nextUserMouse.containsMouse ? "#38802C" : "#52B043"; visible: userModel.count > 1
                        MouseArea { id: nextUserMouse; anchors.fill: parent; hoverEnabled: true; onEntered: { soundBotoes.stop(); soundBotoes.play() } onClicked: root.userIndex = (root.userIndex + 1) % userModel.count }
                    }
                }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Gamerscore  2.605 G"; font.pixelSize: 14; color: "#6C737D" }
            }
        }
        Column {
            spacing: 22
            Rectangle {
                width: 440; height: 215; color: "#26292E"; border.color: passwordInput.activeFocus ? "#52B043" : "#3E434B"; border.width: 4
                Column {
                    anchors.fill: parent; anchors.margins: 24; spacing: 14
                    Text { text: "SENHA DE ACESSO"; font.pixelSize: 15; font.bold: true; font.letterSpacing: 1.5; color: "#52B043" }
                    Rectangle {
                        width: parent.width; height: 48; color: "#FFF"; border.color: "#52B043"; border.width: 2
                        TextInput {
                            id: passwordInput; anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password; font.pixelSize: 20; color: "#111"; focus: true
                            Keys.onReturnPressed: triggerLogin(); Keys.onEnterPressed: triggerLogin()
                        }
                    }
                    Row {
                        width: parent.width; spacing: 16
                        Rectangle {
                            width: 150; height: 40; color: enterBtnMouse.containsMouse ? "#3D8B31" : "#52B043"
                            Text { anchors.centerIn: parent; text: "ENTRAR"; font.pixelSize: 15; font.bold: true; color: "#FFF" }
                            MouseArea { id: enterBtnMouse; anchors.fill: parent; hoverEnabled: true; onEntered: { soundBotoes.stop(); soundBotoes.play() } onClicked: triggerLogin() }
                        }
                        Text { text: root.errorText; color: "#FF6B6B"; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
            Item {
                width: 440; height: 103
                Rectangle {
                    anchors.fill: parent; color: sessionTileMouse.containsMouse ? "#3D8B31" : "#52B043"
                    Column {
                        anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 22; spacing: 4
                        Text { text: "AMBIENTE DE SESSÃO"; font.pixelSize: 13; font.bold: true; color: "#E8F8E5" }
                        Text {
                            property string sName: sessionModel.data(sessionModel.index(root.sessionIndex, 0), Qt.DisplayRole) || "Plasma (X11)"
                            text: (sName.indexOf("/") !== -1 ? "Plasma (X11)" : sName) + (root.sessionMenuOpen ? "  ▲" : "  ▼")
                            font.pixelSize: 20; font.bold: true; color: "#FFF"
                        }
                    }
                    MouseArea {
                        id: sessionTileMouse; anchors.fill: parent; hoverEnabled: true
                        onEntered: { soundBotoes.stop(); soundBotoes.play() }
                        onClicked: {
                            root.sessionMenuOpen = !root.sessionMenuOpen
                            if (root.sessionMenuOpen) soundMenu.play()
                            else { soundBotoes.stop(); soundBotoes.play() }
                        }
                    }
                }
                Rectangle {
                    visible: root.sessionMenuOpen
                    anchors.top: parent.bottom; anchors.topMargin: 6; width: 440
                    height: Math.max(sessionCol.height, 44)
                    color: "#FFFFFF"; border.color: "#52B043"; border.width: 3; z: 50
                    Column {
                        id: sessionCol; width: parent.width
                        Repeater {
                            model: sessionModel
                            Rectangle {
                                width: 434; anchors.horizontalCenter: parent.horizontalCenter; height: 42
                                color: itemMouse.containsMouse ? "#E8F5E6" : "#FFFFFF"
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 18
                                    property string itemLabel: model.name || sessionModel.data(sessionModel.index(index, 0), Qt.DisplayRole) || "Sessão"
                                    text: itemLabel.indexOf("/") !== -1 ? "Plasma (X11)" : itemLabel
                                    font.pixelSize: 17; font.bold: true; color: "#52B043"
                                }
                                MouseArea {
                                    id: itemMouse; anchors.fill: parent; hoverEnabled: true
                                    onEntered: { soundBotoes.stop(); soundBotoes.play() }
                                    onClicked: { root.sessionIndex = index; root.sessionMenuOpen = false }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Row {
        id: bottomBar; opacity: 0.0
        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.margins: 40; spacing: 18
        Rectangle {
            width: rowA.width + 24; height: 46; radius: 6; color: btnAMouse.containsMouse ? "#26000000" : "transparent"
            Row {
                id: rowA; anchors.centerIn: parent; height: 32; spacing: 10
                Rectangle { width: 32; height: 32; radius: 16; anchors.verticalCenter: parent.verticalCenter; color: btnAMouse.containsMouse ? "#3D8B31" : "#52B043"; Text { anchors.centerIn: parent; text: "A"; color: "#FFF"; font.bold: true; font.pixelSize: 16 } }
                Text { text: "Entrar"; color: btnAMouse.containsMouse ? "#111315" : "#3A3F45"; font.pixelSize: 18; font.bold: true; height: 32; verticalAlignment: Text.AlignVCenter }
            }
            MouseArea { id: btnAMouse; anchors.fill: parent; hoverEnabled: true; onEntered: { soundBotoes.stop(); soundBotoes.play() } onClicked: triggerLogin() }
        }
        Rectangle {
            width: rowX.width + 24; height: 46; radius: 6; color: btnXMouse.containsMouse ? "#26000000" : "transparent"
            Row {
                id: rowX; anchors.centerIn: parent; height: 32; spacing: 10
                Rectangle { width: 32; height: 32; radius: 16; anchors.verticalCenter: parent.verticalCenter; color: btnXMouse.containsMouse ? "#1D5BB0" : "#2B7DE9"; Text { anchors.centerIn: parent; text: "X"; color: "#FFF"; font.bold: true; font.pixelSize: 16 } }
                Text { text: "Reiniciar"; color: btnXMouse.containsMouse ? "#111315" : "#3A3F45"; font.pixelSize: 18; font.bold: true; height: 32; verticalAlignment: Text.AlignVCenter }
            }
            MouseArea { id: btnXMouse; anchors.fill: parent; hoverEnabled: true; onEntered: { soundBotoes.stop(); soundBotoes.play() } onClicked: { soundReiniciar.play(); root.pendingAction = "reboot"; actionTimer.start() } }
        }
        Rectangle {
            width: rowY.width + 24; height: 46; radius: 6; color: btnYMouse.containsMouse ? "#26000000" : "transparent"
            Row {
                id: rowY; anchors.centerIn: parent; height: 32; spacing: 10
                Rectangle { width: 32; height: 32; radius: 16; anchors.verticalCenter: parent.verticalCenter; color: btnYMouse.containsMouse ? "#C49200" : "#F5B800"; Text { anchors.centerIn: parent; text: "Y"; color: "#FFF"; font.bold: true; font.pixelSize: 16 } }
                Text { text: "Desligar"; color: btnYMouse.containsMouse ? "#111315" : "#3A3F45"; font.pixelSize: 18; font.bold: true; height: 32; verticalAlignment: Text.AlignVCenter }
            }
            MouseArea { id: btnYMouse; anchors.fill: parent; hoverEnabled: true; onEntered: { soundBotoes.stop(); soundBotoes.play() } onClicked: { soundDesligar.play(); root.pendingAction = "poweroff"; actionTimer.start() } }
        }
    }
    function triggerLogin() {
        soundEntrar.play()
        root.pendingAction = "login"
        actionTimer.start()
    }
    Connections {
        target: sddm
        function onLoginFailed() {
            soundEntrar.stop()
            soundErro.play()
            root.errorText = "Senha incorreta. Tente novamente."
            passwordInput.text = ""
            passwordInput.focus = true
        }
    }
}
