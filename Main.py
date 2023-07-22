import sys
from PySide6 import QtCore, QtWidgets, QtGui

def window():
    app = QtWidgets.QApplication([])
    window = QtWidgets.QMainWindow()
    window.setWindowTitle("Combat Runner")
    window.setGeometry(100, 100, 1000, 800)

    
    listTitle = QtWidgets.QLabel(window)
    listTitle.setText('Monsters')
    listTitle.move(25, 50)

    enemyList = QtWidgets.QListWidget()
    enemyList.move(100, 200)

    window.show()


    sys.exit(app.exec())

window()