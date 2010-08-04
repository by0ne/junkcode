   $(OBJDIR)/codechecker.cmo:    $(OBJDIR)/utilvisitors.cmi \
       $(OBJDIR)/userinput.cmi  $(OBJDIR)/trace.cmi  $(OBJDIR)/pretty.cmi \
       $(OBJDIR)/outofbounds.cmi    $(OBJDIR)/nullptr.cmi \
       $(OBJDIR)/mallocfree.cmi   $(OBJDIR)/dumper.cmi    $(OBJDIR)/data.cmi \
     $(OBJDIR)/cil.cmi   $(OBJDIR)/callgraph.cmi    $(OBJDIR)/bufferoverflow.cmi \
       $(OBJDIR)/codechecker.cmi 
   $(OBJDIR)/codechecker.cmx:    $(OBJDIR)/utilvisitors.cmx \
       $(OBJDIR)/userinput.cmx  $(OBJDIR)/trace.cmx  $(OBJDIR)/pretty.cmx \
       $(OBJDIR)/outofbounds.cmx    $(OBJDIR)/nullptr.cmx \
       $(OBJDIR)/mallocfree.cmx   $(OBJDIR)/dumper.cmx    $(OBJDIR)/data.cmx \
     $(OBJDIR)/cil.cmx   $(OBJDIR)/callgraph.cmx    $(OBJDIR)/bufferoverflow.cmx \
       $(OBJDIR)/codechecker.cmi 
