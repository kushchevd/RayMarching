#pragma once
#include <vector>
#include <string>
#include <fstream>
#include <cstdio>

std::vector<std::string> split(const std::string& s, const char delim);


class Lines
{
    std::istream& is;
    std::string cur;
    void read_one();

public:
    Lines(std::istream& is);

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


void include(std::string infile);



void erase_file(const char* file);