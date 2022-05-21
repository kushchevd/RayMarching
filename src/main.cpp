#include "../include/main.h"
/// default settings
unsigned int SCR_WIDTH = 1920;
unsigned int SCR_HEIGHT = 1080;
unsigned int AA = 1;
Camera camera(glm::vec3(19.0f, 36.0f, -19.0f));
GLfloat lastX   = SCR_WIDTH / 2.0;
GLfloat lastY = SCR_HEIGHT / 2.0;
GLfloat fov = 1.0f;
bool firstMouse = true;
float deltaTime = 0.0f;	// time between current frame and last frame
float lastFrame = 0.0f;

int main()
{
    /// glfw: initialize and configure

    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif

    /// parse config file to get current parametres

    parse_cfg(SCR_WIDTH, SCR_HEIGHT, fov, camera.MovementSpeed, camera.MouseSensitivity, AA);
    /// glfw window creation
    GLFWwindow* window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "RayMarching", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }

    /// callback keyboard, mouse, buffer

    glfwMakeContextCurrent(window);
    glfwSetCursorPosCallback(window, mouse_callback);
    glfwSetScrollCallback(window, scroll_callback);
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);


    /// glad: load all OpenGL function pointers

    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }

    /// parse shader files to include #include option
    include("fragment.glsl");
    /// build and compile our shader program

    Shader ourShader("vertex.glsl", "fragment_compiled.glsl"); // you can name your shader files however you like

    /// erase shader file with includes
    erase_file("fragment_compiled.glsl");
    /// set up vertex data  and configure vertex attributes
    GLfloat vertices[] = {
         1.0f,  1.0f, 0.0f,  // Top Right
         1.0f, -1.0f, 0.0f, // Bottom Right
        -1.0f, -1.0f, 0.0f,  // Bottom Left
        -1.0f,  1.0f, 0.0f // Top Left 
    };
    /// coordinates of 2 triangles to draw rectangle
    GLuint indices[] = {  
        0, 1, 3,  // First Triangle
        1, 2, 3   // Second Triangle
    };
    GLuint VBO, VAO, EBO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);
    /// bind the Vertex Array Object, then bind and set vertex buffers and attribute pointers.
    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    /// ident and load textures to our shader
    unsigned int texture1 = 1, texture2 = 2, texture3 = 3, texture4 = 4;
    LoadTexture(ourShader, texture1, texture2, texture3, texture4);

    /// define antialiasing coef in shader
    ourShader.setInt("AA", AA);

    while (!glfwWindowShouldClose(window))
    {
        /// detect time between frames
        float currentFrame = static_cast<float>(glfwGetTime());
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        // input

        processInput(window);

        /// window background
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        /// bind textures to their id
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture1);

        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture2);

        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, texture3);

        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, texture4);

        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, texture5);

        glActiveTexture(GL_TEXTURE5);
        glBindTexture(GL_TEXTURE_2D, texture6);

        glActiveTexture(GL_TEXTURE6);
        glBindTexture(GL_TEXTURE_2D, texture7);

 
        /// run shader to bind necessesary files
        ourShader.use();
        
        /// define camera direction matrix and camera fov in shader
        ourShader.setMat3("CameraDirection", glm::mat3(camera.Right,camera.Up ,camera.Front));
        ourShader.setFloat("FOV", camera.Zoom);

        /// define global parameters in shader

        GLint fragmentResolutionLocation = glGetUniformLocation(ourShader.ID, "u_resolution");
        glUniform2f(fragmentResolutionLocation, SCR_WIDTH, SCR_HEIGHT);
        

        GLint fragmentMouseLocation = glGetUniformLocation(ourShader.ID, "u_mouse");
        glUniform2f(fragmentMouseLocation, lastX, lastY);

        GLint fragmentScrollLocation = glGetUniformLocation(ourShader.ID, "u_scroll");
        glUniform1f(fragmentScrollLocation, fov);
        
        GLint fragmentTimeLocation = glGetUniformLocation(ourShader.ID, "u_time");
        glUniform1f(fragmentTimeLocation, glfwGetTime());

        GLint fragmentRoLocation = glGetUniformLocation(ourShader.ID, "ro");
        glUniform3f(fragmentRoLocation, camera.Position[0], camera.Position[1], camera.Position[2]);

     
        
        
        
        glBindVertexArray(VAO);
        /// draw window where scene render
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

        /// glfw: swap buffers and poll IO events 
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    ///clear buffers
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteBuffers(1, &EBO);
    /// glfw: terminate, clearing all previously allocated GLFW resources.
    glfwTerminate();
    return 0;
}
/// process keyboard inputs
void processInput(GLFWwindow* window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);


    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        camera.ProcessKeyboard(Camera_Movement::FORWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        camera.ProcessKeyboard(Camera_Movement::BACKWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        camera.ProcessKeyboard(Camera_Movement::LEFT, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        camera.ProcessKeyboard(Camera_Movement::RIGHT, deltaTime);
}

// glfw: whenever the window size changed (by OS or user resize) this callback function executes
void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
}

/// detect mouse position on the screen
void mouse_callback(GLFWwindow* window, double xposIn, double yposIn)
{
    float xpos = static_cast<float>(xposIn);
    float ypos = static_cast<float>(yposIn);

    if (firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }

    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos; 

    lastX = xpos;
    lastY = ypos;

    camera.ProcessMouseMovement(xoffset, yoffset);
}
/// detect mouse scroll
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset)
{
    camera.ProcessMouseScroll(static_cast<float>(yoffset));
}