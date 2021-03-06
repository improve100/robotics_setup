#!/bin/bash
# source: https://gist.github.com/phatblat/1713458
# Save script's current directory
DIR=$(pwd)

set -e
set -u
set -x

echo "############################"
echo "# costar_stack ROS library"
echo "############################"
echo "# Robot User Interface"
echo "# for flexible task creation "
echo ""
echo "# github.com/cpaxton/costar_stack"


# ROS must be installed first, assuming it is in default /opt/ros location
if [ ! -d /opt/ros ]; then
    ./ros.sh
fi

location="cpaxton" # github.com/ahundt/Tasks # I have some patches here
#location="lcsr" # github.com/jrl-umi3218/Tasks # ongoing development happens here
#location="jorisv" # github.com/jorisv/Tasks # original repository location

# TODO(ahundt) switch back to master once standardized cmake changes are merged, see https://github.com/jrl-umi3218/jrl-cmakemodules/pull/103
branch="master"
#branch="package" # this branch adds standard cmake package configuration


. /etc/lsb-release # get ubuntu version number


if [ "$DISTRIB_RELEASE" = "16.04" ]; then
    ROSVERSION="kinetic"
	# TODO(ahundt) How to install fcl? should "soem" be installed?
	# TODO(ahundt) Are there univeral robot ros-industrial kinetic binaries?
	sudo apt-get install -y ros-kinetic-moveit # ros-kinetic-universal-robot ros-kinetic-ur-msgs #  ros-indigo-fcl

	source /opt/ros/kinetic/setup.bash
fi


if [ "$DISTRIB_RELEASE" = "14.04" ]; then
    ROSVERSION="indigo"
	sudo apt-get install -y ros-indigo-moveit-full ros-indigo-fcl ros-indigo-soem

	source /opt/ros/indigo/setup.bash
fi

# openni2 and friends is optional
sudo apt-get install -y libopenni2-0 libopenni2-dev openni2-doc openni2-utils ros-${ROSVERSION}-openni2-camera ros-${ROSVERSION}-openni2-launch

# instructor python dependencies
sudo apt-get install -y qt4-designer qt4-dev-tools python-qt4 python-qt4-dev python-wxversion wx-common python-wxgtk3.0

# many of these are required, ${ROSVERSION} will be indigo, kinetic as appropriate
sudo apt-get install -y python-catkin-tools liburdfdom-headers-dev ros-${ROSVERSION}-control-msgs ros-${ROSVERSION}-gazebo-ros-control ros-${ROSVERSION}-python-orocos-kdl xdot libccd-dev ros-${ROSVERSION}-ros-control ros-${ROSVERSION}-octomap-msgs ros-${ROSVERSION}-gazebo-plugins ros-${ROSVERSION}-pcl-ros ros-${ROSVERSION}-socketcan-interface ros-${ROSVERSION}-rqt-gui ros-${ROSVERSION}-object-recognition-msgs ros-${ROSVERSION}-realtime-tools ros-${ROSVERSION}-position-controllers ros-${ROSVERSION}-robot-state-publisher ros-${ROSVERSION}-joint-state-controller python-bloom

# ceres solver is needed for handeye_calib_camodocal
# which performs hand eye calibration
./ceres.sh

if [ -e "/opt/ros/${ROSVERSION}/setup.bash"]; then
	source /opt/ros/${ROSVERSION}/setup.bash
fi

cd $HOME/src
mkdir -p costar_ws/src
cd costar_ws
catkin init
cd src

# TODO(ahundt) add better recovery and update utilities, and use specific release versions
if [ ! -d ~/src/costar_ws/src/costar_stack ]; then
	git clone https://github.com/${location}/costar_stack.git
fi

if [ ! -d ~/src/costar_ws/src/iiwa_stack ]; then
	git clone https://github.com/cpaxton/iiwa_stack.git
	# git clone https://github.com/SalvoVirga/iiwa_stack.git # This is the upstream location
fi

if [ ! -d ~/src/costar_ws/src/robotiq ]; then
	#git clone https://github.com/ros-industrial/robotiq.git # This is the upstream location
	git clone https://github.com/jhu-lcsr/robotiq.git -b ${ROSVERSION}-devel
fi

if [ ! -d ~/src/costar_ws/src/rqt_dot ]; then
	git clone https://github.com/jbohren/rqt_dot.git
fi

if [ ! -d ~/src/costar_ws/src/ar_track_alvar ]; then
	git clone https://github.com/ros-perception/ar_track_alvar.git -b ${ROSVERSION}-devel
	# ar_track_alvar_msgs is directly in ar_track_alvar, but is here for reference
	# git clone https://github.com/sniekum/ar_track_alvar_msgs.git
fi

if [ ! -d ~/src/costar_ws/src/hrl-kdl ]; then
	git clone https://github.com/gt-ros-pkg/hrl-kdl.git
fi

	# xdot has been moved directly into costar_stack, but is here for reference
	#git clone https://github.com/cpaxton/xdot.git
	#git clone https://github.com/ThomasTimm/ur_modern_driver.git # This is the upstream location
if [ ! -d ~/src/costar_ws/src/ur_modern_driver ]; then
	git clone https://github.com/ahundt/ur_modern_driver.git -b ${ROSVERSION}-devel
fi

	# note: there are also binary versions on 14.04
if [ ! -d ~/src/costar_ws/src/universal_robot ]; then
	git clone https://github.com/ros-industrial/universal_robot.git -b ${ROSVERSION}-devel
fi

if [ "$DISTRIB_RELEASE" = "16.04" ]; then
    if [ ! -d ~/src/costar_ws/src/soem ]; then
	    git clone https://github.com/UTNuclearRoboticsPublic/soem.git
	fi
fi

if [ ! -d ~/src/costar_ws/src/objrecransac ]; then
	# Optional for vision utilities
	git clone https://github.com/jhu-lcsr/ObjRecRANSAC.git objrecransac
	# git clone https://github.com/ahundt/ObjRecRANSAC.git objrecransac
	# git clone https://github.com/tum-mvp/ObjRecRANSAC.git objrecransac # This is the upstream location
fi

if [ ! -d ~/src/costar_ws/src/costar_stack ]; then
	# https://github.com/jhu-lcsr/handeye_calib_camodocal
	git clone git@github.com:jhu-lcsr/handeye_calib_camodocal.git
fi

if [ ! -d ~/src/costar_ws/src/costar_stack ]; then
	# works on both indigo and kinetic
	git clone https://github.com/cpaxton/dmp.git -b indigo
fi

if [ -e ../devel/setup.bash ]; then
    source ../devel/setup.bash
fi

cd costar_stack
git pull
cd ../iiwa_stack
git pull
cd ../robotiq
git pull
cd ../rqt_dot
git pull
cd ../ar_track_alvar
git pull
cd ../hrl-kdl
git pull
cd ../ur_modern_driver
git pull
cd ../universal_robot
git pull

if [ "$DISTRIB_RELEASE" = "16.04" ]; then
    cd ../soem
	git pull
fi

cd ../objrecransac
git pull
cd ../handeye_calib_camodocal
git pull
cd ../dmp
git pull
cd ..


# TODO(ahundt) FIX HACK: build objrecransac with standard cmake build, otherwise the headers won't be found. Is this on both kinetic and indigo?
cd objrecransac
mkdir -p build
cd build
cmake ..
make -j install
cd ../..

#echo "Ignore COSTAR_PERCEPTION until you have installed its dependencies."
#touch costar_stack/costar_perception/CATKIN_IGNORE

# There is a strange quirk where sp_segmenter optionally depends on ObjRecRANSAC
# Building that package first helps resolve the dependency.
catkin build objrecransac
catkin build --continue



cd $DIR