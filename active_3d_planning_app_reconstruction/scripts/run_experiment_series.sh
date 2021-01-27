#!/bin/bash

# *** Args (need to be set) ***
n_experiments=10
target_dir="/home/lukas/Documents/MT/Data/exp2_spiral"		# Can reuse same dir to add experiments
clear_voxblox_maps=true		# Irreversibly remove maps after evaluation to save disk space
experiment=1		# For auto configs of exp1/2 (city/windmill)


# *** Run experiments ***
echo "Starting experiment${experiment} series of ${n_experiments} runs at '${target_dir}'!"

# Create dir
if [ ! -d "$target_dir" ]; then
  mkdir $target_dir
fi

# Use auto config for experiments (to make sure nothing can go wrong!)
if [[ $experiment == 1 ]]; then
  experiment_name="small_house"
  file_obj="/home/yves/dataset/vr_planner/small_house/small_house.obj"
  file_texture="/home/yves/dataset/vr_planner/small_house/small_house.png"
  time_limit=5
  voxel_size=0.1
  gt_file="/home/yves/dataset/vr_planner/small_house/gt_surface.ply"
elif [[ $experiment == 2 ]]; then
  cfg="experiment2.yaml"
  time_limit=
  pcl="/home/lukas/Documents/MT/experiment2/gt_surface_pcl.ply"
fi

# Run the experiments
for (( i=1; i<=n_experiments; i++ ))
do

  # start simulation
  roslaunch ar_planner mav_sim.launch file_obj:=$file_obj file_texture:=$file_texture experiment:=$experiment_name x_0:=-7 x_ctrl_0:=-7 z_ctrl_0:=2

  # start planner
  roslaunch ar_planner informative_planner_node.launch experiment:=$experiment_name voxel_size:=$voxel_size data_directory:=$target_dir time_limit:=$time_limit

  # evaluate
  roslaunch ar_planner evaluate_informative_planner.launch target_directory:=$target_dir gt_file_path:=$gt_file clear_voxblox_maps:=$clear_voxblox_maps create_meshes:=false


  # run experiment
#  roslaunch mav_active_3d_planning run_experiment.launch data_directory:=$target_dir record_data:=true experiment_config:=$cfg data_frequency:=$freq time_limit:=$dur
  # run spiral
   # roslaunch mav_active_3d_planning run_spiral.launch data_directory:=$target_dir
  # evaluate
   # roslaunch mav_active_3d_planning evaluate_experiment.launch target_directory:=$target_dir method:=recent series:=false clear_voxblox_maps:=$clear_voxblox_maps gt_file_path:=$pcl evaluate:=true
done

roslaunch ar_planner evaluate_informative_planner.launch target_directory:=$target_dir series:=true
