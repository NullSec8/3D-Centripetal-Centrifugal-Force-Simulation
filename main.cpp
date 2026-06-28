#include <GLFW/glfw3.h>
#include <algorithm>
#include <iostream>
#include <cmath>
#include <vector>
#include <string>
#include <sstream>
#include <iomanip>

// Madhësia e dritares
const int WIDTH = 1200;
const int HEIGHT = 800;
constexpr float PI = 3.14159265358979323846f;

// Parametrat e simulimit
struct Paramatrat {
    float rrezja = 4.0f;      // r (m)
    float omega = 1.5f;       // shpejtësia këndore (rad/s)
    float masa = 1.0f;        // masa (kg)
    float koha = 0.0f;        // koha e simulimit
    bool pauzuar = false;
    bool shfaqForcenCentripetale = true;  // Ndryshuar emrin
    bool shfaqForcenCentrifugale = false; // Shtuar opsion për centrifugale
    bool shfaqShpejtesine = true;         // Shtuar shpejtësinë
    bool shfaqRrugen = true;
    bool perspektiva3D = true;
    float shkallaVizuale = 0.1f; // Shkalla për vizualizimin e forcës
} params;

// Kamera 3D
float cameraAngleX = 45.0f;
float cameraAngleY = 30.0f;
float cameraDistance = 15.0f;

// Pozicioni i objektit
float objX = 4.0f;
float objY = 0.0f;
float objZ = 0.0f;

// Lista për rrugën
struct Pika {
    float x, y, z;
};
std::vector<Pika> rruga;

bool normalizeVec3(float& x, float& y, float& z) {
    float len = std::sqrt(x * x + y * y + z * z);
    if (len < 1e-6f) {
        return false;
    }
    x /= len;
    y /= len;
    z /= len;
    return true;
}

void crossVec3(float ax, float ay, float az,
               float bx, float by, float bz,
               float& rx, float& ry, float& rz) {
    rx = ay * bz - az * by;
    ry = az * bx - ax * bz;
    rz = ax * by - ay * bx;
}

// Funksion për të llogaritur matricën e projektimit të perspektivës
void setPerspective(float fovy, float aspect, float zNear, float zFar) {
    float f = 1.0f / std::tan(fovy * 0.5f * PI / 180.0f);
    
    float matrix[16] = {
        f / aspect, 0.0f, 0.0f, 0.0f,
        0.0f, f, 0.0f, 0.0f,
        0.0f, 0.0f, (zFar + zNear) / (zNear - zFar), -1.0f,
        0.0f, 0.0f, (2.0f * zFar * zNear) / (zNear - zFar), 0.0f
    };
    
    glMultMatrixf(matrix);
}

// Funksion për të llogaritur matricën e pamjes (lookAt)
void setLookAt(float eyeX, float eyeY, float eyeZ,
               float centerX, float centerY, float centerZ,
               float upX, float upY, float upZ) {
    float fx = centerX - eyeX;
    float fy = centerY - eyeY;
    float fz = centerZ - eyeZ;

    // Shmang ndarjen me zero kur kamera dhe qendra përputhen
    if (!normalizeVec3(fx, fy, fz)) {
        return;
    }

    // Llogarit vektorin s (djathtas) nga f × up
    float sx, sy, sz;
    crossVec3(fx, fy, fz, upX, upY, upZ, sx, sy, sz);

    // Nëse up është paralel me drejtimin e shikimit, përdor një up alternativ
    if (!normalizeVec3(sx, sy, sz)) {
        float altUpX = 0.0f;
        float altUpY = 1.0f;
        float altUpZ = 0.0f;
        if (std::fabs(fy) > 0.99f) {
            altUpX = 1.0f;
            altUpY = 0.0f;
            altUpZ = 0.0f;
        }
        crossVec3(fx, fy, fz, altUpX, altUpY, altUpZ, sx, sy, sz);
        if (!normalizeVec3(sx, sy, sz)) {
            return;
        }
    }

    // Llogarit vektorin u (lart)
    float ux, uy, uz;
    crossVec3(sx, sy, sz, fx, fy, fz, ux, uy, uz);
    
    float matrix[16] = {
        sx, ux, -fx, 0.0f,
        sy, uy, -fy, 0.0f,
        sz, uz, -fz, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f
    };
    
    glMultMatrixf(matrix);
    glTranslatef(-eyeX, -eyeY, -eyeZ);
}

// Funksion për të vizatuar një sfërë të thjeshtë (përdor rrathë për përafrim)
void drawSphere(float x, float y, float z, float radius, int segments = 12) {
    glPushMatrix();
    glTranslatef(x, y, z);
    
    // Ngjyra e verdhë
    glColor3f(1.0f, 1.0f, 0.0f);
    
    // Vizato disa rrathë për të krijuar një sfërë të përafërt
    // Rrethi horizontal (XY plane)
    glBegin(GL_LINE_LOOP);
    for (int i = 0; i < segments; i++) {
        float angle = 2.0f * PI * i / segments;
        glVertex3f(radius * std::cos(angle), radius * std::sin(angle), 0);
    }
    glEnd();
    
    // Rrethi vertikal (XZ plane)
    glBegin(GL_LINE_LOOP);
    for (int i = 0; i < segments; i++) {
        float angle = 2.0f * PI * i / segments;
        glVertex3f(radius * std::cos(angle), 0, radius * std::sin(angle));
    }
    glEnd();
    
    // Rrethi vertikal (YZ plane)
    glBegin(GL_LINE_LOOP);
    for (int i = 0; i < segments; i++) {
        float angle = 2.0f * PI * i / segments;
        glVertex3f(0, radius * std::cos(angle), radius * std::sin(angle));
    }
    glEnd();
    
    // Mbushje e thjeshtë
    glColor4f(1.0f, 1.0f, 0.0f, 0.3f);
    glBegin(GL_TRIANGLE_FAN);
    glVertex3f(0, 0, 0);
    for (int i = 0; i <= segments; i++) {
        float angle = 2.0f * PI * i / segments;
        glVertex3f(radius * std::cos(angle), radius * std::sin(angle), 0);
    }
    glEnd();
    
    glPopMatrix();
}

// Funksion për të vizatuar një rreth
void drawCircle(float cx, float cy, float cz, float radius, int segments = 50) {
    glBegin(GL_LINE_LOOP);
    for (int i = 0; i < segments; i++) {
        float angle = 2.0f * PI * i / segments;
        glVertex3f(cx + radius * std::cos(angle), cy + radius * std::sin(angle), cz);
    }
    glEnd();
}

// Funksion për të vizatuar një shigjetë të thjeshtë
void drawArrow(float x1, float y1, float z1, float x2, float y2, float z2, 
               float r, float g, float b, float thickness = 2.0f) {
    glColor3f(r, g, b);
    glLineWidth(thickness);
    
    // Vija kryesore
    glBegin(GL_LINES);
    glVertex3f(x1, y1, z1);
    glVertex3f(x2, y2, z2);
    glEnd();
    
    // Koka e shigjetës
    float dx = x2 - x1;
    float dy = y2 - y1;
    float dz = z2 - z1;
    float length = std::sqrt(dx*dx + dy*dy + dz*dz);
    
    if (length > 0.01f) {
        dx /= length;
        dy /= length;
        dz /= length;
        
        // Gjej një vektor pingul (për drejtimin e kokës)
        float px, py, pz;
        if (std::fabs(dx) > 0.1f || std::fabs(dy) > 0.1f) {
            px = -dy;
            py = dx;
            pz = 0;
        } else {
            px = 0;
            py = -dz;
            pz = dy;
        }
        
        // Normalizo pingulen
        float pLength = std::sqrt(px*px + py*py + pz*pz);
        if (pLength > 0.01f) {
            px /= pLength;
            py /= pLength;
            pz /= pLength;
            
            // Shkallëzo për madhësinë e kokës
            px *= 0.1f;
            py *= 0.1f;
            pz *= 0.1f;
            
            // Pikat për trekëndëshin
            float headSize = 0.3f;
            float headX1 = x2 - dx * headSize + px;
            float headY1 = y2 - dy * headSize + py;
            float headZ1 = z2 - dz * headSize + pz;
            
            float headX2 = x2 - dx * headSize - px;
            float headY2 = y2 - dy * headSize - py;
            float headZ2 = z2 - dz * headSize - pz;
            
            glBegin(GL_TRIANGLES);
            glVertex3f(x2, y2, z2);
            glVertex3f(headX1, headY1, headZ1);
            glVertex3f(headX2, headY2, headZ2);
            glEnd();
        }
    }
}

// Funksion për të vizatuar akset koordinative
void drawAxes() {
    glLineWidth(2.0f);
    
    // Boshti X (e kuqe)
    glColor3f(1.0f, 0.0f, 0.0f);
    glBegin(GL_LINES);
    glVertex3f(0, 0, 0);
    glVertex3f(8, 0, 0);
    glEnd();
    
    // Boshti Y (e gjelbër)
    glColor3f(0.0f, 1.0f, 0.0f);
    glBegin(GL_LINES);
    glVertex3f(0, 0, 0);
    glVertex3f(0, 8, 0);
    glEnd();
    
    // Boshti Z (e kaltër)
    glColor3f(0.0f, 0.0f, 1.0f);
    glBegin(GL_LINES);
    glVertex3f(0, 0, 0);
    glVertex3f(0, 0, 8);
    glEnd();
}

// Funksion për të vizatuar një grid të thjeshtë
void drawGrid() {
    glColor3f(0.3f, 0.3f, 0.3f);
    glLineWidth(1.0f);
    
    glBegin(GL_LINES);
    // Linjat e gridit në rrafshin X-Y
    for (int i = -10; i <= 10; i++) {
        // Linjat paralele me boshtin X
        glVertex3f(-10, i, 0);
        glVertex3f(10, i, 0);
        // Linjat paralele me boshtin Y
        glVertex3f(i, -10, 0);
        glVertex3f(i, 10, 0);
    }
    glEnd();
}

// Kontrolli nga tastiera (MODIFIKUAR për forcën centripetale)
void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) {
    if (action == GLFW_PRESS || action == GLFW_REPEAT) {
        switch (key) {
            // Kontrolli i parametrave
            case GLFW_KEY_UP:    params.omega += 0.1f; break;
            case GLFW_KEY_DOWN:  params.omega = std::max(0.1f, params.omega - 0.1f); break;
            case GLFW_KEY_RIGHT: params.rrezja += 0.2f; break;
            case GLFW_KEY_LEFT:  params.rrezja = std::max(0.5f, params.rrezja - 0.2f); break;
            case GLFW_KEY_W:     params.masa += 0.1f; break;
            case GLFW_KEY_S:     params.masa = std::max(0.1f, params.masa - 0.1f); break;
            case GLFW_KEY_EQUAL:
            case GLFW_KEY_KP_ADD:
                params.shkallaVizuale += 0.05f;
                break;
            case GLFW_KEY_MINUS:
            case GLFW_KEY_KP_SUBTRACT:
                params.shkallaVizuale = std::max(0.01f, params.shkallaVizuale - 0.05f);
                break;
            
            // Kontrolli i kameras
            case GLFW_KEY_A: cameraAngleX -= 5.0f; break;
            case GLFW_KEY_D: cameraAngleX += 5.0f; break;
            case GLFW_KEY_Q: cameraAngleY = std::max(5.0f, cameraAngleY - 5.0f); break;
            case GLFW_KEY_E: cameraAngleY = std::min(175.0f, cameraAngleY + 5.0f); break;
            case GLFW_KEY_Z: cameraDistance = std::max(2.0f, cameraDistance - 1.0f); break;
            case GLFW_KEY_X: cameraDistance = std::min(80.0f, cameraDistance + 1.0f); break;
            
            // Kontrolli i vizualizimit (MODIFIKUAR)
            case GLFW_KEY_1: params.shfaqForcenCentripetale = !params.shfaqForcenCentripetale; break;
            case GLFW_KEY_2: params.shfaqForcenCentrifugale = !params.shfaqForcenCentrifugale; break;
            case GLFW_KEY_3: params.shfaqShpejtesine = !params.shfaqShpejtesine; break;
            case GLFW_KEY_4: params.shfaqRrugen = !params.shfaqRrugen; break;
            case GLFW_KEY_5: params.perspektiva3D = !params.perspektiva3D; break;
            case GLFW_KEY_P: params.pauzuar = !params.pauzuar; break;
            case GLFW_KEY_SPACE: // Reset
                params.rrezja = 4.0f;
                params.omega = 1.5f;
                params.masa = 1.0f;
                params.koha = 0.0f;
                rruga.clear();
                break;
            case GLFW_KEY_ESCAPE:
                glfwSetWindowShouldClose(window, GLFW_TRUE);
                break;
        }
    }
}

// Funksioni për të nxjerrë informacionin fizik (MODIFIKUAR për centripetale)
std::string getPhysicsInfo() {
    float Fc = params.masa * params.omega * params.omega * params.rrezja;
    float v = params.omega * params.rrezja;
    float T = 2.0f * PI / params.omega;
    float ac = v * v / params.rrezja;  // Nxitimi centripetal
    
    std::ostringstream oss;
    oss << "FORCA CENTRIPETALE | F=" << Fc << "N | m=" << params.masa 
        << "kg | ω=" << params.omega << "rad/s | r=" << params.rrezja 
        << "m | v=" << v << "m/s | a=" << ac << "m/s² | T=" << T << "s";
    return oss.str();
}

// Funksioni kryesor
int main() {
    // Inicializo GLFW
    if (!glfwInit()) {
        std::cerr << "Gabim: Nuk mund te inicializohet GLFW!" << std::endl;
        return -1;
    }
    
    // Krijo dritaren
    GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, "Simulim 3D - Forca Centripetale", NULL, NULL);
    if (!window) {
        std::cerr << "Gabim: Nuk mund te krijohet dritarja!" << std::endl;
        glfwTerminate();
        return -1;
    }
    
    glfwMakeContextCurrent(window);
    glfwSetKeyCallback(window, key_callback);
    
    // Shfaq udhëzimet (MODIFIKUAR për centripetale)
    std::cout << "\n=== SIMULIM 3D I FORCES CENTRIPETALE ===\n";
    std::cout << "FORMULA: F = m × ω² × r = m × v² / r\n\n";
    std::cout << "KONTROLLET:\n";
    std::cout << "  UP/DOWN     : Ndrysho ω (shpejtesine kendore)\n";
    std::cout << "  LEFT/RIGHT  : Ndrysho r (rrezen)\n";
    std::cout << "  W/S         : Ndrysho m (masen)\n";
    std::cout << "  +/-         : Ndrysho madhesine e shigjetes\n";
    std::cout << "  A/D         : Rrotullo horizontalisht\n";
    std::cout << "  Q/E         : Rrotullo vertikalisht\n";
    std::cout << "  Z/X         : Zmadho/Zvogeloi\n\n";
    std::cout << "VIZUALIZIMI:\n";
    std::cout << "  1           : Ndez/Fik forcën centripetale (BLLU)\n";
    std::cout << "  2           : Ndez/Fik forcën centrifugale (E KUQE)\n";
    std::cout << "  3           : Ndez/Fik shpejtësinë (GJELBËR)\n";
    std::cout << "  4           : Ndez/Fik rrugën\n";
    std::cout << "  5           : Ndez/Fik 3D\n";
    std::cout << "  P           : Pauzo/Perseri\n";
    std::cout << "  SPACE       : Rifillo\n";
    std::cout << "  ESC         : Dil\n";
    std::cout << "==========================================\n\n";
    
    std::cout << "SHENIM:\n";
    std::cout << "- Forca Centripetale (blu) është forca e VËRTETË drejt qendrës\n";
    std::cout << "- Forca Centrifugale (e kuqe) është forca FIKTIVE larg qendrës\n";
    std::cout << "- Shpejtësia (gjelbër) është gjithmonë tangjente me rrethin\n";
    
    // Konfiguro OpenGL
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Kufizo FPS për të zvogëluar ngarkesën
    glfwSwapInterval(1);
    
    double lastTime = glfwGetTime();
    int frameCount = 0;
    double lastFPSUpdate = lastTime;
    
    // Loop-i kryesor
    while (!glfwWindowShouldClose(window)) {
        double currentTime = glfwGetTime();
        float deltaTime = currentTime - lastTime;
        lastTime = currentTime;

        int framebufferWidth = 0;
        int framebufferHeight = 0;
        glfwGetFramebufferSize(window, &framebufferWidth, &framebufferHeight);
        if (framebufferWidth <= 0 || framebufferHeight <= 0) {
            glfwPollEvents();
            continue;
        }
        
        // Përditëso fizikën nëse nuk është pauzuar
        if (!params.pauzuar) {
            params.koha += deltaTime;
            
            // Llogarit pozicionin e objektit
            objX = params.rrezja * cos(params.omega * params.koha);
            objY = params.rrezja * sin(params.omega * params.koha);
            objZ = 0.0f;
            
            // Ruaj në rrugë
            rruga.push_back({objX, objY, objZ});
            if (rruga.size() > 100) { // REDUKTUAR nga 200 në 100 pika
                rruga.erase(rruga.begin());
            }
        }
        
        frameCount++;
        double elapsed = currentTime - lastFPSUpdate;
        if (elapsed >= 1.0) {
            double fps = frameCount / elapsed;
            std::ostringstream title;
            title << getPhysicsInfo() << " | FPS=" << std::fixed << std::setprecision(1) << fps;
            glfwSetWindowTitle(window, title.str().c_str());
            frameCount = 0;
            lastFPSUpdate = currentTime;
        }
        
        // Pastro buffers
        glClearColor(0.08f, 0.08f, 0.12f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glViewport(0, 0, framebufferWidth, framebufferHeight);
        
        // Konfiguro pamjen
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        
        float aspect = static_cast<float>(framebufferWidth) / static_cast<float>(framebufferHeight);
        
        if (params.perspektiva3D) {
            // Perspektivë 3D
            setPerspective(45.0f, aspect, 0.1f, 100.0f);
        } else {
            // Pamje 2D/Orthographic
            glOrtho(-10.0f * aspect, 10.0f * aspect, -10.0f, 10.0f, -100.0f, 100.0f);
        }
        
        // Konfiguro model-view
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        
        // Poziciono kamerën
        float camX = cameraDistance * std::sin(cameraAngleY * PI / 180.0f) * std::cos(cameraAngleX * PI / 180.0f);
        float camZ = cameraDistance * std::sin(cameraAngleY * PI / 180.0f) * std::sin(cameraAngleX * PI / 180.0f);
        float camY = cameraDistance * std::cos(cameraAngleY * PI / 180.0f);
        
        setLookAt(camX, camY, camZ,  // Pozicioni i kamerës
                  0.0f, 0.0f, 0.0f,  // Pika ku shikon
                  0.0f, 0.0f, 1.0f); // Drejtimi lart
        
        // Vizato elementet
        drawGrid();
        drawAxes();
        
        // Vizato orbitën
        if (params.shfaqRrugen) {
            glColor3f(0.5f, 0.5f, 0.5f);
            glLineWidth(1.0f);
            drawCircle(0, 0, 0, params.rrezja, 32); // REDUKTUAR segments nga 50 në 32
        }
        
        // Vizato rrugën e kaluar
        if (params.shfaqRrugen && rruga.size() > 1) {
            glColor3f(0.0f, 0.8f, 0.0f);
            glLineWidth(1.5f); // REDUKTUAR nga 2.0f
            glBegin(GL_LINE_STRIP);
            // Vizato vetëm çdo pikë të dytë për të kursyer
            for (size_t i = 0; i < rruga.size(); i += 2) {
                glVertex3f(rruga[i].x, rruga[i].y, rruga[i].z);
            }
            glEnd();
        }
        
        // Vizato objektin
        drawSphere(objX, objY, objZ, 0.3f, 10); // REDUKTUAR segments nga 12 në 10
        
        // Vizato qendrën
        glColor3f(1.0f, 1.0f, 1.0f);
        drawSphere(0, 0, 0, 0.1f, 8); // REDUKTUAR segments
        
        // Llogarit forcat dhe vektorët
        float Fc = params.masa * params.omega * params.omega * params.rrezja;
        float v = params.omega * params.rrezja;
        float angle = std::atan2(objY, objX);
        float cosA = std::cos(angle);
        float sinA = std::sin(angle);
        
        // Vizato FORCËN CENTRIPETALE (BLLU - drejt qendrës)
        if (params.shfaqForcenCentripetale) {
            float scale = Fc * params.shkallaVizuale;
            // Forca centripetale është drejt qendrës, prandaj minus
            float forceX = objX - cosA * scale;
            float forceY = objY - sinA * scale;
            
            drawArrow(objX, objY, objZ, forceX, forceY, objZ, 
                     0.0f, 0.5f, 1.0f, 3.0f); // Bluu
        }
        
        // Vizato FORCËN CENTRIFUGALE (E KUQE - larg qendrës)
        if (params.shfaqForcenCentrifugale) {
            float scale = Fc * params.shkallaVizuale;
            // Forca centrifugale është larg qendrës
            float forceX = objX + cosA * scale;
            float forceY = objY + sinA * scale;
            
            drawArrow(objX, objY, objZ, forceX, forceY, objZ, 
                     1.0f, 0.0f, 0.0f, 2.0f); // E kuqe
        }
        
        // Vizato SHPËJTËSINË (GJELBËR - tangjente)
        if (params.shfaqShpejtesine) {
            float scale = v * 0.5f;
            // Shpejtësia është tangjente (-sin, cos)
            float velX = objX - sinA * scale;
            float velY = objY + cosA * scale;
            
            drawArrow(objX, objY, objZ, velX, velY, objZ, 
                     0.0f, 0.8f, 0.0f, 2.0f); // Gjelbër
        }
        
        // Vizato një legjendë të thjeshtë në këndin e sipërm
        glMatrixMode(GL_PROJECTION);
        glPushMatrix();
        glLoadIdentity();
        glOrtho(0, framebufferWidth, framebufferHeight, 0, -1, 1);
        
        glMatrixMode(GL_MODELVIEW);
        glPushMatrix();
        glLoadIdentity();
        
        // Kthehu në model-view
        glPopMatrix();
        glMatrixMode(GL_PROJECTION);
        glPopMatrix();
        glMatrixMode(GL_MODELVIEW);
        
        // Shkëmbë buffer-t dhe kontrollo event-et
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    // Pastrim
    glfwDestroyWindow(window);
    glfwTerminate();
    
    return 0;
}
