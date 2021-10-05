#
# Makefile
#

RASM  = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink
RSIM  = /home/fac/wrc/bin/rsim

# Suffixes to be used or created
.SUFFIXES:	.asm .obj .lst .out

#
# Transformation rule: .asm into .obj
#
.asm.obj:
	$(RASM) -l $*.asm > $*.lst

#
# Transformation rule: .obj into .out
#
.obj.out:
	$(RLINK) -m -o $*.out $*.obj > $*.map




# Main target

connect4.out:	connect4.obj

run:
	- $(RSIM) connect4.out

debug:
	- $(RSIMi) -d connect4.out

clean:
	rm *.obj *.lst *.out *.map


