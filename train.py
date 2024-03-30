import os
import numpy as np

import gymnasium as gym
from gymnasium import spaces
from gymnasium.wrappers import TimeLimit

from stable_baselines3 import DDPG
from stable_baselines3.common.monitor import Monitor

import gym_server

serverIP = 'localhost'
serverPort = '8000'

projectPath = os.path.join(os.getcwd(), "Environment")
godotPath = "flatpak run org.godotengine.Godot"
scenePath = "./environment.tscn"
# exeCmd = "Environment/frc_run.sh --display-driver 'x11' --rendering-driver 'vulkan' --rendering-method 'forward_plus' --gpu-abort --verbose"
exeCmd = ("cd {} && {} {} "
            "--display-driver 'headless' "
            "--rendering-driver 'vulkan' "
            "--rendering-method 'forward_plus' "
            "--verbose --debug-collisions").format(projectPath, godotPath, scenePath)

# Linear X-Axis, Linear Y-Axis, Rotational X-Axis
actionSpace = spaces.Box(low=np.array([-1.0, -1.0, -1.0], dtype=np.float32), 
                         high=np.array([1.0, 1.0, 1.0], dtype=np.float32),
                         dtype=np.float32)

observationSpace = spaces.Box(low=np.array([
    0., # Robot X
    0., # Robot Y
    -3.1415927, # Robot Angle in radians
    -100., # Robot Angular Velocity
    -100., # Robot Linear Velocity X
    -100., # Robot Linear Velocity Y
    0., # Note X
    0., # Note Y
], dtype=np.float32),
high=np.array([
    512.,
    512.,
    3.1415927,
    100.,
    100.,
    100.,
    0.,
    0.,
], dtype=np.float32),
dtype=np.float32)

renderPath = "renderFrames/"

print("Getting ready to make...")

env = gym.make('server-v0', serverIP=serverIP, serverPort=serverPort, exeCmd=exeCmd,
               action_space=actionSpace, observation_space=observationSpace,
               window_render=True, renderPath=renderPath)

env = Monitor(TimeLimit(env, max_episode_steps=250))
