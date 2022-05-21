#include "../lunclude.h"

std::vector<std::string> split(const std::string& s, const char delim)
{
    std::vector<std::string> v;
    auto p = std::begin(s);
    for (auto q = std::find(p, std::end(s), delim); q != std::end(s); q = std::find(++p, std::end(s), delim))
    {
        v.emplace_back(p, q);
        p = q;
    }
    if (p != std::end(s))
        v.emplace_back(p, std::end(s));
    return v;
}

void Lines::read_one() { std::getline(is, cur); }
Lines::Lines(std::istream& is) : is{is} { read_one(); }
void include(std::string infile)
{
    std::ifstream in{ infile };
    std::ofstream fout("fragment_compiled.glsl", std::ios_base::out | std::ios_base::trunc);
    int i = 0;
    for (std::string& s : Lines{ in })
    {
        std::string string_to_replace = "";
        std::vector<std::string> token = split(s, ' ');
        if (token.size() >= 2 && token[0] == "#include" && i)
        {
            token[1].erase(remove(token[1].begin(), token[1].end(), '\"'), token[1].end());
            std::ifstream sourceFile(token[1]);
            s.assign((std::istreambuf_iterator<char>(sourceFile)), std::istreambuf_iterator<char>());
        }
        if (i || 1)
        {
            fout << s << std::endl;
        }
        i = 1;
    }
    fout.close();
    return;
}


void erase_file(const char* file)
{
    remove(file);
}