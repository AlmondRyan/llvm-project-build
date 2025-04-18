; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -global-isel -mtriple=amdgcn-mesa-mesa3d -mcpu=tonga -stop-after=irtranslator %s -o - | FileCheck %s

; Check that we correctly skip over disabled inputs
define amdgpu_ps void @disabled_input(float inreg %arg0, float %psinput0, float %psinput1) #1 {
  ; CHECK-LABEL: name: disabled_input
  ; CHECK: bb.1.main_body:
  ; CHECK-NEXT:   liveins: $sgpr2, $vgpr0
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY $sgpr2
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY $vgpr0
  ; CHECK-NEXT:   [[DEF:%[0-9]+]]:_(s32) = G_IMPLICIT_DEF
  ; CHECK-NEXT:   G_INTRINSIC_W_SIDE_EFFECTS intrinsic(@llvm.amdgcn.exp), 0, 15, [[COPY]](s32), [[COPY]](s32), [[COPY]](s32), [[COPY1]](s32), 0, 0
  ; CHECK-NEXT:   S_ENDPGM 0
main_body:
  call void @llvm.amdgcn.exp.f32(i32 0, i32 15, float %arg0, float %arg0, float %arg0, float %psinput1, i1 false, i1 false) #0
  ret void
}

define amdgpu_ps void @disabled_input_struct(float inreg %arg0, { float, float } %psinput0, float %psinput1) #1 {
  ; CHECK-LABEL: name: disabled_input_struct
  ; CHECK: bb.1.main_body:
  ; CHECK-NEXT:   liveins: $sgpr2, $vgpr0
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY $sgpr2
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY $vgpr0
  ; CHECK-NEXT:   [[DEF:%[0-9]+]]:_(s32) = G_IMPLICIT_DEF
  ; CHECK-NEXT:   [[COPY2:%[0-9]+]]:_(s32) = COPY [[DEF]](s32)
  ; CHECK-NEXT:   G_INTRINSIC_W_SIDE_EFFECTS intrinsic(@llvm.amdgcn.exp), 0, 15, [[COPY]](s32), [[COPY]](s32), [[COPY]](s32), [[COPY1]](s32), 0, 0
  ; CHECK-NEXT:   S_ENDPGM 0
main_body:
  call void @llvm.amdgcn.exp.f32(i32 0, i32 15, float %arg0, float %arg0, float %arg0, float %psinput1, i1 false, i1 false) #0
  ret void
}

define amdgpu_ps float @vgpr_return(i32 %vgpr) {
  ; CHECK-LABEL: name: vgpr_return
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   liveins: $vgpr0
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY $vgpr0
  ; CHECK-NEXT:   $vgpr0 = COPY [[COPY]](s32)
  ; CHECK-NEXT:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %cast = bitcast i32 %vgpr to float
  ret float %cast
}

define amdgpu_ps i32 @sgpr_return_i32(i32 %vgpr) {
  ; CHECK-LABEL: name: sgpr_return_i32
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   liveins: $vgpr0
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY $vgpr0
  ; CHECK-NEXT:   [[INTRINSIC_CONVERGENT:%[0-9]+]]:_(s32) = G_INTRINSIC_CONVERGENT intrinsic(@llvm.amdgcn.readfirstlane), [[COPY]](s32)
  ; CHECK-NEXT:   $sgpr0 = COPY [[INTRINSIC_CONVERGENT]](s32)
  ; CHECK-NEXT:   SI_RETURN_TO_EPILOG implicit $sgpr0
  ret i32 %vgpr
}

define amdgpu_ps i64 @sgpr_return_i64(i64 %vgpr) {
  ; CHECK-LABEL: name: sgpr_return_i64
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   liveins: $vgpr0, $vgpr1
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY $vgpr0
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY $vgpr1
  ; CHECK-NEXT:   [[MV:%[0-9]+]]:_(s64) = G_MERGE_VALUES [[COPY]](s32), [[COPY1]](s32)
  ; CHECK-NEXT:   [[UV:%[0-9]+]]:_(s32), [[UV1:%[0-9]+]]:_(s32) = G_UNMERGE_VALUES [[MV]](s64)
  ; CHECK-NEXT:   [[INTRINSIC_CONVERGENT:%[0-9]+]]:_(s32) = G_INTRINSIC_CONVERGENT intrinsic(@llvm.amdgcn.readfirstlane), [[UV]](s32)
  ; CHECK-NEXT:   $sgpr0 = COPY [[INTRINSIC_CONVERGENT]](s32)
  ; CHECK-NEXT:   [[INTRINSIC_CONVERGENT1:%[0-9]+]]:_(s32) = G_INTRINSIC_CONVERGENT intrinsic(@llvm.amdgcn.readfirstlane), [[UV1]](s32)
  ; CHECK-NEXT:   $sgpr1 = COPY [[INTRINSIC_CONVERGENT1]](s32)
  ; CHECK-NEXT:   SI_RETURN_TO_EPILOG implicit $sgpr0, implicit $sgpr1
  ret i64 %vgpr
}

define amdgpu_ps <2 x i32> @sgpr_return_v2i32(<2 x i32> %vgpr) {
  ; CHECK-LABEL: name: sgpr_return_v2i32
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   liveins: $vgpr0, $vgpr1
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY $vgpr0
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY $vgpr1
  ; CHECK-NEXT:   [[BUILD_VECTOR:%[0-9]+]]:_(<2 x s32>) = G_BUILD_VECTOR [[COPY]](s32), [[COPY1]](s32)
  ; CHECK-NEXT:   [[UV:%[0-9]+]]:_(s32), [[UV1:%[0-9]+]]:_(s32) = G_UNMERGE_VALUES [[BUILD_VECTOR]](<2 x s32>)
  ; CHECK-NEXT:   [[INTRINSIC_CONVERGENT:%[0-9]+]]:_(s32) = G_INTRINSIC_CONVERGENT intrinsic(@llvm.amdgcn.readfirstlane), [[UV]](s32)
  ; CHECK-NEXT:   $sgpr0 = COPY [[INTRINSIC_CONVERGENT]](s32)
  ; CHECK-NEXT:   [[INTRINSIC_CONVERGENT1:%[0-9]+]]:_(s32) = G_INTRINSIC_CONVERGENT intrinsic(@llvm.amdgcn.readfirstlane), [[UV1]](s32)
  ; CHECK-NEXT:   $sgpr1 = COPY [[INTRINSIC_CONVERGENT1]](s32)
  ; CHECK-NEXT:   SI_RETURN_TO_EPILOG implicit $sgpr0, implicit $sgpr1
  ret <2 x i32> %vgpr
}

define amdgpu_ps { i32, i32 } @sgpr_struct_return_i32_i32(i32 %vgpr0, i32 %vgpr1) {
  ; CHECK-LABEL: name: sgpr_struct_return_i32_i32
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   liveins: $vgpr0, $vgpr1
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY $vgpr0
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY $vgpr1
  ; CHECK-NEXT:   [[DEF:%[0-9]+]]:_(s32) = G_IMPLICIT_DEF
  ; CHECK-NEXT:   [[INTRINSIC_CONVERGENT:%[0-9]+]]:_(s32) = G_INTRINSIC_CONVERGENT intrinsic(@llvm.amdgcn.readfirstlane), [[COPY]](s32)
  ; CHECK-NEXT:   $sgpr0 = COPY [[INTRINSIC_CONVERGENT]](s32)
  ; CHECK-NEXT:   [[INTRINSIC_CONVERGENT1:%[0-9]+]]:_(s32) = G_INTRINSIC_CONVERGENT intrinsic(@llvm.amdgcn.readfirstlane), [[COPY1]](s32)
  ; CHECK-NEXT:   $sgpr1 = COPY [[INTRINSIC_CONVERGENT1]](s32)
  ; CHECK-NEXT:   SI_RETURN_TO_EPILOG implicit $sgpr0, implicit $sgpr1
  %insertvalue0 = insertvalue { i32, i32 } poison, i32 %vgpr0, 0
  %value = insertvalue { i32, i32 } %insertvalue0, i32 %vgpr1, 1
  ret { i32, i32 } %value
}

define amdgpu_ps ptr addrspace(3) @sgpr_return_p3i8(ptr addrspace(3) %vgpr) {
  ; CHECK-LABEL: name: sgpr_return_p3i8
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   liveins: $vgpr0
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(p3) = COPY $vgpr0
  ; CHECK-NEXT:   [[PTRTOINT:%[0-9]+]]:_(s32) = G_PTRTOINT [[COPY]](p3)
  ; CHECK-NEXT:   [[INTRINSIC_CONVERGENT:%[0-9]+]]:_(s32) = G_INTRINSIC_CONVERGENT intrinsic(@llvm.amdgcn.readfirstlane), [[PTRTOINT]](s32)
  ; CHECK-NEXT:   $sgpr0 = COPY [[INTRINSIC_CONVERGENT]](s32)
  ; CHECK-NEXT:   SI_RETURN_TO_EPILOG implicit $sgpr0
  ret ptr addrspace(3) %vgpr
}

define amdgpu_ps ptr addrspace(1) @sgpr_return_p1i8(ptr addrspace(1) %vgpr) {
  ; CHECK-LABEL: name: sgpr_return_p1i8
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   liveins: $vgpr0, $vgpr1
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY $vgpr0
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY $vgpr1
  ; CHECK-NEXT:   [[MV:%[0-9]+]]:_(p1) = G_MERGE_VALUES [[COPY]](s32), [[COPY1]](s32)
  ; CHECK-NEXT:   [[UV:%[0-9]+]]:_(s32), [[UV1:%[0-9]+]]:_(s32) = G_UNMERGE_VALUES [[MV]](p1)
  ; CHECK-NEXT:   [[INTRINSIC_CONVERGENT:%[0-9]+]]:_(s32) = G_INTRINSIC_CONVERGENT intrinsic(@llvm.amdgcn.readfirstlane), [[UV]](s32)
  ; CHECK-NEXT:   $sgpr0 = COPY [[INTRINSIC_CONVERGENT]](s32)
  ; CHECK-NEXT:   [[INTRINSIC_CONVERGENT1:%[0-9]+]]:_(s32) = G_INTRINSIC_CONVERGENT intrinsic(@llvm.amdgcn.readfirstlane), [[UV1]](s32)
  ; CHECK-NEXT:   $sgpr1 = COPY [[INTRINSIC_CONVERGENT1]](s32)
  ; CHECK-NEXT:   SI_RETURN_TO_EPILOG implicit $sgpr0, implicit $sgpr1
  ret ptr addrspace(1) %vgpr
}

define amdgpu_ps <2 x i16> @sgpr_return_v2i16(<2 x i16> %vgpr) {
  ; CHECK-LABEL: name: sgpr_return_v2i16
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   liveins: $vgpr0
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(<2 x s16>) = COPY $vgpr0
  ; CHECK-NEXT:   [[BITCAST:%[0-9]+]]:_(s32) = G_BITCAST [[COPY]](<2 x s16>)
  ; CHECK-NEXT:   [[INTRINSIC_CONVERGENT:%[0-9]+]]:_(s32) = G_INTRINSIC_CONVERGENT intrinsic(@llvm.amdgcn.readfirstlane), [[BITCAST]](s32)
  ; CHECK-NEXT:   $sgpr0 = COPY [[INTRINSIC_CONVERGENT]](s32)
  ; CHECK-NEXT:   SI_RETURN_TO_EPILOG implicit $sgpr0
  ret <2 x i16> %vgpr
}

declare void @llvm.amdgcn.exp.f32(i32 immarg, i32 immarg, float, float, float, float, i1 immarg, i1 immarg)  #0

attributes #0 = { nounwind }
attributes #1 = { "InitialPSInputAddr"="0x00002" }
