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
                return FastqRecord.new(name,seq,qual)
        end
        def has_next?
                return !@f.eof?
        end
        def self.tofastqstr(r)
                r.name.chomp + "\n" + r.seq + "\n+\n" + r.qual
        end
end

class FastqRecord
        attr_reader :name, :seq, :qual
        def initialize(name,seq,qual)
                @name=name
                @seq=seq
                @qual=qual
        end
        def to_s
                @name + "\n" + @seq + "\n+\n" + @qual
        end

end
        
