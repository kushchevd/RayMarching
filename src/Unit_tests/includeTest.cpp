#include "includeTest.h"

 void includeTest(const char* file) {
	include(file);
	system("pause");
	std::cin.get();
	erase_file("fragmrent_compailed.glsl");

}