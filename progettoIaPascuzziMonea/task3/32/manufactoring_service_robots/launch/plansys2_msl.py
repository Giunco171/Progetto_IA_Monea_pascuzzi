import os

from ament_index_python.packages import get_package_share_directory

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description():
    # Get the launch directory
    example_dir = get_package_share_directory('manufactoring_service_robots')
    namespace = LaunchConfiguration('namespace')

    declare_namespace_cmd = DeclareLaunchArgument(
        'namespace',
        default_value='',
        description='Namespace')

    plansys2_cmd = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(os.path.join(
            get_package_share_directory('plansys2_bringup'),
            'launch',
            'plansys2_bringup_launch_monolithic.py')),
        launch_arguments={
          'model_file': example_dir + '/pddl/domain.pddl',
          'namespace': namespace
          }.items())

    # Specify the actions
    empty_box_in_loc_cmd = Node(
        package='manufactoring_service_robots',
        executable='empty_box_in_loc_action_node',
        name='empty_box_in_loc_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    empty_box_in_ws_cmd = Node(
        package='manufactoring_service_robots',
        executable='empty_box_in_ws_action_node',
        name='empty_box_in_ws_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    enter_ws_cmd = Node(
        package='manufactoring_service_robots',
        executable='enter_ws_action_node',
        name='enter_ws_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])   # Create the launch description and populate
    
    exit_ws_cmd = Node(
        package='manufactoring_service_robots',
        executable='exit_ws_action_node',
        name='exit_ws_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])
    
    fill_box_in_loc_cmd = Node(
        package='manufactoring_service_robots',
        executable='fill_box_in_loc_action_node',
        name='fill_box_in_loc_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])
        
    fill_box_in_warehouse_cmd = Node(
        package='manufactoring_service_robots',
        executable='fill_box_in_warehouse_action_node',
        name='fill_box_in_warehouse_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])
    
    fill_box_in_ws_cmd = Node(
        package='manufactoring_service_robots',
        executable='fill_box_in_ws_action_node',
        name='fill_box_in_ws_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])
    
    load_boxes_from_loc_cmd = Node(
        package='manufactoring_service_robots',
        executable='load_boxes_from_loc_action_node',
        name='load_boxes_from_loc_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])
        
    load_boxes_from_ws_cmd = Node(
        package='manufactoring_service_robots',
        executable='load_boxes_from_ws_action_node',
        name='load_boxes_from_ws_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])
    
    move_to_loc_cmd = Node(
        package='manufactoring_service_robots',
        executable='move_to_loc_action_node',
        name='move_to_loc_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])
        
        
    move_to_warehouse_cmd = Node(
        package='manufactoring_service_robots',
        executable='move_to_warehouse_action_node',
        name='move_to_warehouse_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])
        
   
    put_down_box_in_loc_cmd = Node(
        package='manufactoring_service_robots',
        executable='put_down_box_in_loc_action_node',
        name='put_down_box_in_loc_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])
        
        
    put_down_box_in_ws_cmd = Node(
        package='manufactoring_service_robots',
        executable='put_down_box_in_ws_action_node',
        name='put_down_box_in_ws_action_node',
        namespace=namespace,
        output='screen',
        parameters=[])
   
    ld = LaunchDescription()

    ld.add_action(declare_namespace_cmd)

    # Declare the launch options
    ld.add_action(plansys2_cmd)

    ld.add_action(empty_box_in_loc_cmd)
    ld.add_action(empty_box_in_ws_cmd)
    ld.add_action(enter_ws_cmd)
    ld.add_action(exit_ws_cmd)
    ld.add_action(fill_box_in_loc_cmd)
    ld.add_action(fill_box_in_warehouse_cmd)
    ld.add_action(fill_box_in_ws_cmd)
    ld.add_action(load_boxes_from_loc_cmd)
    ld.add_action(load_boxes_from_ws_cmd)
    ld.add_action(move_to_loc_cmd)
    ld.add_action(move_to_warehouse_cmd)
    ld.add_action(put_down_box_in_loc_cmd)
    ld.add_action(put_down_box_in_ws_cmd)
    
    return ld
