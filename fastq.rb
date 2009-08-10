#!/usr/bin/env ruby
require 'rubygems'
require 'amatch'
require 'ostruct'
include Amatch
class String
        def each_substring(len)
                (0..length).each{|i|
                        yield [self[i..i+len-1],i]
                }
        end
end

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

class TrimmedFastq
        def initialize(fastq,qs,qe)
                @f=fastq
                @queriesStart=qs
                @queriesEnd=qe
        end
        def each
                @f.each do |record|
                        @queriesStart.each{|q|
                                lastPos = -1
                                bestDist = 3
                                record.seq.each_substring(q.pattern.length){|str,pos|
                                        if (q.match(str)<bestDist)
                                                lastPos = pos + q.pattern.length
                                                bestDist = q.match(str)
                                        end
                                }
                                if (lastPos > -1)
                                        #  puts "lastPos " + lastPos.to_s
                                        #  puts "seq " + record.seq
                                        #  puts "dropping " + record.seq[0..lastPos-1]
                                        #  puts "keeping " + record.seq[lastPos..record.seq.length-1]
                                        record.seq=record.seq[lastPos..record.seq.length-1]
                                        record.qual=record.qual[lastPos..record.qual.length-1]
                                end
                        }
                        record.seq="" if record.seq==nil
                        @queriesEnd.each{|q|
                                lastPos = record.seq.length
                                bestDist = 3
                       
                                record.seq.each_substring(q.pattern.length){|str,pos|
                                        if (q.match(str)<bestDist)
                                                puts q.pattern + " matches " + str
                                                lastPos=pos
                                                bestDist = q.match(str)
                                        end
                                }
                                if (lastPos < record.seq.length)
                                        record.seq=record.seq[0..lastPos-1]
                                        record.qual=record.qual[0..lastPos-1]
                                end
                        }
                        record.seq="" if record.seq==nil
                        record.qual="" if record.qual==nil
                        yield record
                end
        end
end

#queriesStart = [Levenshtein.new("CT")]
#queriesEnd = [Levenshtein.new("GA")]


#f = Fastq.new("test.fastq")
#ft = TrimmedFastq.new(f,queriesStart,queriesEnd)
#ft.each{|r|
#        puts(r.name.chomp + "\n" + r.seq + "\n+\n" + r.qual)
#}
