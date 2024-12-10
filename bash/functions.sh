#!/bin/bash

#commands

home () {
    echo "running ls  at home"
    ls /home/nao3
    echo "it this ok you you? "
}

etc () {
    echo "running ls at etc"
    ls /etc
    echo "it this ok you you? "
}

var () {
    echo "running ls at var"
    ls /var
    echo "it this ok you you? "
}


# submenu
stage2 () {
  PS2='select one from above?: '
  echo "enter 2nd stage"
  ops2=("yes" "no" "abort")
  select ans2 in "${ops2[@]}"
  do
      case $ans2 in
          "yes")
              echo "cool, going back" 
              stage1
              ;;
          "no")
              echo "so sad"
              stage1             
              ;;
          "abort")
              exit
              ;;
          *) echo "invalid option $REPLY";;
      esac
  done
}


# Bash Menu Script Example 
stage1 () {
echo "Please select a directory: "
PS1='Please select a directory: '
ops1=("home" "etc" "var" "exit")
select ans1 in "${ops1[@]}"
do
    case $ans1 in
        "home")
            echo "you chose choice 1"
            home
            stage2
            ;;
        "etc")
            echo "you chose choice 2"
            etc
            stage2
            ;;
        "var")
            echo "you chose choice $REPLY which is var"
            var
            stage2
            ;;
        "exit")
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
}

#script
echo "Welcome, please read: "
stage1