 .code32
foo:
	pavgb		%xmm1,%xmm0
	pavgb		(%edx),%xmm1
	pavgw		%xmm3,%xmm2
	pavgw		(%esp,1),%xmm3
	pextrw		$0x0,%xmm1,%eax
	pinsrw		$0x1,(%ecx),%xmm1
	pinsrw		$0x2,%edx,%xmm2
	pmaxsw		%xmm1,%xmm0
	pmaxsw		(%edx),%xmm1
	pmaxub		%xmm2,%xmm2
	pmaxub		(%esp,1),%xmm3
	pminsw		%xmm5,%xmm4
	pminsw		(%esi),%xmm5
	pminub		%xmm7,%xmm6
	pminub		(%eax),%xmm7
	pmovmskb	%xmm5,%eax
	pmulhuw		%xmm5,%xmm4
	pmulhuw		(%esi),%xmm5
	psadbw		%xmm7,%xmm6
	psadbw		(%eax),%xmm7
	pshufd		$0x1,%xmm2,%xmm3
	pshufd		$0x4,0x0(%ebp),%xmm6
	pshufhw		$0x1,%xmm2,%xmm3
	pshufhw		$0x4,0x0(%ebp),%xmm6
	pshuflw		$0x1,%xmm2,%xmm3
	pshuflw		$0x4,0x0(%ebp),%xmm6
	movntq		%xmm2,(%eax)
	punpcklbw	0x90909090(%eax),%xmm2
	punpcklwd	0x90909090(%eax),%xmm2
	punpckldq	0x90909090(%eax),%xmm2
	packsswb	0x90909090(%eax),%xmm2
	pcmpgtb		0x90909090(%eax),%xmm2
	pcmpgtw		0x90909090(%eax),%xmm2
	pcmpgtd		0x90909090(%eax),%xmm2
	packuswb	0x90909090(%eax),%xmm2
	punpckhbw	0x90909090(%eax),%xmm2
	punpckhwd	0x90909090(%eax),%xmm2
	punpckhdq	0x90909090(%eax),%xmm2
	packssdw	0x90909090(%eax),%xmm2
	movd		0x90909090(%eax),%xmm2
	movq		0x90909090(%eax),%xmm2
	psrlw		$0x90,%xmm0
	psrld		$0x90,%xmm0
	psrlq		$0x90,%xmm0
	pcmpeqb		0x90909090(%eax),%xmm2
	pcmpeqw		0x90909090(%eax),%xmm2
	pcmpeqd		0x90909090(%eax),%xmm2
	movd		%xmm2,0x90909090(%eax)
	movq		%xmm2,0x90909090(%eax)
	psrlw		0x90909090(%eax),%xmm2
	psrld		0x90909090(%eax),%xmm2
	psrlq		0x90909090(%eax),%xmm2
	pmullw		0x90909090(%eax),%xmm2
	psubusb		0x90909090(%eax),%xmm2
	psubusw		0x90909090(%eax),%xmm2
	pand		0x90909090(%eax),%xmm2
	paddusb		0x90909090(%eax),%xmm2
	paddusw		0x90909090(%eax),%xmm2
	pandn		0x90909090(%eax),%xmm2
	psraw		0x90909090(%eax),%xmm2
	psrad		0x90909090(%eax),%xmm2
	pmulhw		0x90909090(%eax),%xmm2
	psubsb		0x90909090(%eax),%xmm2
	psubsw		0x90909090(%eax),%xmm2
	por		0x90909090(%eax),%xmm2
	paddsb		0x90909090(%eax),%xmm2
	paddsw		0x90909090(%eax),%xmm2
	pxor		0x90909090(%eax),%xmm2
	psllw		0x90909090(%eax),%xmm2
	pslld		0x90909090(%eax),%xmm2
	psllq		0x90909090(%eax),%xmm2
	pmaddwd		0x90909090(%eax),%xmm2
	psubb		0x90909090(%eax),%xmm2
	psubw		0x90909090(%eax),%xmm2
	psubd		0x90909090(%eax),%xmm2
	paddb		0x90909090(%eax),%xmm2
	paddw		0x90909090(%eax),%xmm2
	paddd		0x90909090(%eax),%xmm2
 .p2align 4
