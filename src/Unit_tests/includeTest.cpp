#include "includeTest.h"

 void includeTest() {
	include("fragment.glsl");
	system("pause");
	std::cin.get();
	erase_file("fragment_compiled.glsl");
}