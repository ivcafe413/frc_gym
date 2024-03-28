# import gymnasium as gym
import gym
# from gymnasium import spaces
from gym import spaces

import numpy as np

import gym_server

import os

serverIP = '127.0.0.1'
serverPort = '8888'

# projectPath = os.path.join(os.getcwd(), "Environment")
# projectPath = "Environment"
# godotPath = "C:\\godot\\bin\\godot.windows.editor.x86_64.exe"
# godotPath = '"C:/Program Files/Godot/Godot_v4.2-stable_win64.exe" --upwards environment.tscn'
# scenePath = "--upwards environment.tscn"
# projectPath = "project.godot"
# exeCmd = "{} {}".format(godotPath, scenePath)
exeCmd = "Environment/frc_run.x86_64"

actionSpace = spaces.Box(low=np.array([-1.0, -1.0, -1.0], dtype=np.float32), # Linear X-Axis, Linear Y-Axis, Rotational X-Axis
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

renderPath = "renderFrames"
if not os.path.exists(renderPath):
    os.makedirs(renderPath)

env = gym.make('server-v0', serverIP=serverIP, serverPort=serverPort, exeCmd=exeCmd,
               action_space=actionSpace, observation_space=observationSpace,
               window_render=True, renderPath=renderPath)

new_action = env.action_space.sample()

env.reset()
for i in range(0, 5):
    print(env.step(new_action))

env.render()

env.close()
del env