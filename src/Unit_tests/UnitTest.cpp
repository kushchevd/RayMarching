#include "UnitTest.h"

void RunTest(void (*func)(), const std::string& test_name) {
	try {
		func();
	}
	catch (std::runtime_error& err) {
		std::cerr << test_name << " fail: " << err.what() << std::endl;
	}
}