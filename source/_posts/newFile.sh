#!/bin/bash


Tags=
Category=
Title=
CurState="title"
IsParam="true"
PostPath="/e/blog/source/_posts/" #将这里替换为你的_posts 目录地址
#PostPath="./"
Date=`date +%F`
Date="$Date `date +%T`"

if [ "$#" -lt "1" ];then
    echo "Input Error"
    exit
fi

i=0
j=0
for argv in $*
do
#   echo $argv
    if [ $argv = "-t" ];then
        CurState="Tags"
        IsParam="true"
    elif [ $argv = "-c" ];then
        CurState="Category"
        IsParam="true"
    else 
        IsParam="false"
    fi

    if [ $IsParam = "false" ];then
        if [ $CurState = "Tags" ];then
            let i++
            Tags="$Tags $argv"
        elif [ $CurState = "Category" ];then
            let j++
            Category="$Category $argv"
        else
            Title="$Title $argv"
        fi
    fi
done

#echo "Tags=$Tags"
#echo "Category=$Category"
#echo "Title=$Title"
#echo "CurDate=$Date"
for path in $Category 
do
    if test -d "$PostPath$path" ; then
        PostPath="$PostPath$path/"
        continue
    else
        mkdir $PostPath$path
        PostPath="$PostPath$path/"
    fi
done
for CurFile in $Title
do

    cd $PostPath
    mkdir $CurFile
    CurTitle=$CurFile   
    CurFile="$CurFile.md"
    if [ $j = "1" ];then
        Category=`echo "$Category" |sed -n "s/^[ ]*//gp"` 
    else
        Category=`echo "$Category" |sed -n "s/^[ ]*//gp"|sed -n "s/ /,/gp"` 
    fi

    if [ $i = "1" ];then
        Tags=`echo "$Tags" |sed -n "s/^[ ]*//gp"` 
    else
        Tags=`echo "$Tags" |sed -n "s/^[ ]*//gp"|sed -n "s/ /,/gp"` 
    fi

    echo "---" >>"$CurFile"
    echo "title: $CurTitle" >>"$CurFile"
    echo "category: [$Category]" >>"$CurFile"
    echo "tags: [$Tags]" >>"$CurFile"
    echo "toc: true" >>"$CurFile"
    echo "date: $Date" >>"$CurFile"
    echo "---" >>"$CurFile"

done
