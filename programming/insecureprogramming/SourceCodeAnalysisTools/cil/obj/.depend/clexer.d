  $(OBJDIR)/clexer.cmo:  $(OBJDIR)/pretty.cmi   $(OBJDIR)/machdep.cmo \
      $(OBJDIR)/lexerhack.cmo  $(OBJDIR)/errormsg.cmi   $(OBJDIR)/cprint.cmo \
      $(OBJDIR)/cparser.cmi   $(OBJDIR)/cabs.cmo   $(OBJDIR)/clexer.cmi 
  $(OBJDIR)/clexer.cmx:  $(OBJDIR)/pretty.cmx   $(OBJDIR)/machdep.cmx \
      $(OBJDIR)/lexerhack.cmx  $(OBJDIR)/errormsg.cmx   $(OBJDIR)/cprint.cmx \
      $(OBJDIR)/cparser.cmx   $(OBJDIR)/cabs.cmx   $(OBJDIR)/clexer.cmi 
