#pragma once
#include "parseTest.h"
#include "includeTest.h"
#include <stdexcept>
#include <sstream>
#include <string>

void RunTest(void (*func)(), const std::string& test_name);