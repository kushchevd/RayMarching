#include <vector>
#include <string>
#include <fstream>
#include <cstdio>

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

bool fileExists(const std::string& filename)
{
    return std::ifstream{ filename }.good();
}

class Lines
{
    std::istream& is;
    std::string cur;
    void read_one() { std::getline(is, cur); }

public:
    Lines(std::istream& is) : is{ is } { read_one(); }

    class iterator
    {
    public:
        using value_type = std::string;
        using reference = std::string&;
        using pointer = std::string*;
        using const_reference = const std::string&;
        using const_pointer = const std::string*;
        using iterator_category = std::forward_iterator_tag;
        using difference_type = int;
    private:
        Lines* src;
        friend class Lines;
        iterator(Lines* src) noexcept : src{ src } {
        }
    public:
        iterator() noexcept : src{} {}
        reference operator*() noexcept { return src->cur; }
        const_reference operator*() const noexcept { return src->cur; }
        bool operator==(const iterator& other) const noexcept
        {
            return (src == other.src) || (!src && !other.src->is) || (!src->is && !other.src);
        }
        bool operator!=(const iterator& other) const noexcept
        {
            return !(*this == other);
        }
        iterator& operator++()
        {
            src->read_one();
            return *this;
        }
        iterator operator++(int)
        {
            auto temp = *this;
            operator++();
            return temp;
        }
    };
    iterator begin() noexcept { return{ this }; }
    iterator end() noexcept { return{}; }
private:
    friend class iterator;
};

//example: include("fragment.glsl");
void include(std::string infile)        //#include
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
            //std::cout << s << std::endl;
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