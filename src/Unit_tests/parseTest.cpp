#include "parseTest.h"

int main() {
	unsigned int SCR_WIDTH = -1;
	unsigned int SCR_HEIGHT = -1;
	unsigned int AA = -1;
	float speed = -1.;
	float sensitivity = -1.;
	GLfloat fov = -1.;

	parse_cfg(SCR_WIDTH, SCR_HEIGHT, fov, speed, sensitivity, AA);

	std::cout << "SCREEN WIDTH=" << SCR_WIDTH << "\nSCREEN HEIGHT=" << SCR_HEIGHT << "\nFOV=" << fov << "\nCAMERA SPEED=" << speed << "\nCAMERA SENSITIVITY=" << sensitivity << "\nAA= " << AA << "\n";
}