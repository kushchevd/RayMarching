#include "../parse.h"
 
void parse_cfg(unsigned int& SCR_WIDTH, unsigned int& SCR_HEIGHT, GLfloat& fov, float& speed, float& sensivity, unsigned int& AA) {
    std::ifstream cFile("config.txt");

    if (cFile.is_open()) {
        std::string line;

        while (getline(cFile, line)) {
            line.erase(std::remove_if(line.begin(), line.end(), isspace), line.end());

            if (line[0] == '#' || line.empty()) {
                continue;
            }
            else {
                auto delimiterPos = line.find("=");
                auto name = line.substr(0, delimiterPos);
                auto value = line.substr(delimiterPos + 1);

                if (name == "SCR_WIDTH")
                    SCR_WIDTH = std::stoi(value);
                else if (name == "SCR_HEIGHT")
                    SCR_HEIGHT = std::stoi(value);
                else if (name == "fov")
                    fov = std::stof(value);
                else if (name == "speed")
                    speed = std::stof(value);
                else if (name == "sensivity")
                    sensivity = std::stof(value);
                else if (name == "AA")
                    AA = std::stof(value);
                else
                    throw std::runtime_error("Wrong config format");
            }
        }

    }
    else {
        std::cerr
            << "Couldn't open config file for reading.\n Using default values.";
    }
}