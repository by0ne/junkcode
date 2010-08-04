  $(OBJDIR)/patch.cmo:  $(OBJDIR)/trace.cmi  $(OBJDIR)/pretty.cmi \
      $(OBJDIR)/cprint.cmo   $(OBJDIR)/cabsvisit.cmi   $(OBJDIR)/cabs.cmo \
      $(OBJDIR)/patch.cmi 
  $(OBJDIR)/patch.cmx:  $(OBJDIR)/trace.cmx  $(OBJDIR)/pretty.cmx \
      $(OBJDIR)/cprint.cmx   $(OBJDIR)/cabsvisit.cmx   $(OBJDIR)/cabs.cmx \
      $(OBJDIR)/patch.cmi 
