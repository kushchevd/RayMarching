#pragma once
#include <GLFW/glfw3.h>
#include <iostream>
#include <fstream>
#include <string>

void parse_cfg(unsigned int& SCR_WIDTH, unsigned int& SCR_HEIGHT, GLfloat& fov, float& speed, float& sensivity, unsigned int& AA);