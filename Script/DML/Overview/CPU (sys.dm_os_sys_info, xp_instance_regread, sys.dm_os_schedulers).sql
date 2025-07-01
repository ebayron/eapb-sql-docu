-- Retrieve CPU Model and Speed (Using sys.dm_os_sys_info)
SELECT
    socket_count AS [CPU_Sockets], -- Number of physical processor sockets
    cores_per_socket AS [Cores_Per_Socket], -- Number of physical cores per socket 
    cpu_count AS [Logicial_CPUs],  -- Total number of logical CPUs
    scheduler_count AS [Schedulers], -- Total number of schedulers used by SQL Server
    numa_node_count AS [NUMA_Nodes], -- Number of NUMA nodes available
    hyperthread_ratio AS [Hyperthreading_Ratio], -- Number of logical CPUs per physical core
    max_workers_count AS [Max_Worker_Threads] -- Maximum number of worker threads available
FROM sys.dm_os_sys_info;

-- Retrieve CPU Model and Name

EXEC xp_instance_regread 
    'HKEY_LOCAL_MACHINE', 
    'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 
    'ProcessorNameString'

-- Retrieve CPU Usage and Load (Using sys.dm_os_schedulers)
SELECT 
    scheduler_id AS [Scheduler_ID], -- SQL Server Scheduler ID
    cpu_id AS [CPU_ID], -- CPU ID assigned by the OS
    status AS [Scheduler_Status], -- Status of the scheduler (VISIBLE ONLINE, HIDDEN ONLINE, etc.)
    is_online AS [Is_Online], -- 1 = Online, 0 = Offline
    is_idle AS [Is_Idle], -- 1 = Idle, 0 = Active
    current_tasks_count AS [Current_Tasks], -- Number of tasks assigned to this scheduler
    runnable_tasks_count AS [Runnable_Tasks], -- Number of tasks waiting to execute
    work_queue_count AS [Work_Queue_Count], -- Number of tasks in queue
    active_workers_count AS [Active_Workers] -- Number of workers actively executing tasks
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255; -- Exclude internal schedulers
