#!/usr/bin/env ruby
require 'rubygems'
require 'ostruct'

class Fastq
        def initialize(file)
                @f=File.open(file,'r')
        end
        def each
                while self.has_next?
                        yield self.next
                end
        end
        def next
                name = @f.readline.sub("^@","").chomp
                seq = @f.readline.chomp
                @f.readline
                qual=@f.readline.chomp
                return OpenStruct.new(:name => name, :seq => seq, :qual => qual)
        end
        def has_next?
                return !@f.eof?
        end
        def self.tofastqstr(r)
                r.name.chomp + "\n" + r.seq + "\n+\n" + r.qual
        end
end

