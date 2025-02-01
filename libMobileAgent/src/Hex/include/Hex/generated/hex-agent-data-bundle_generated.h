// automatically generated by the FlatBuffers compiler, do not modify


#ifndef FLATBUFFERS_GENERATED_HEXAGENTDATABUNDLE_COM_NEWRELIC_MOBILE_FBS_H_
#define FLATBUFFERS_GENERATED_HEXAGENTDATABUNDLE_COM_NEWRELIC_MOBILE_FBS_H_

#include "flatbuffers/flatbuffers.h"

// Ensure the included flatbuffers.h is the same version as when this file was
// generated, otherwise it may not be compatible.
static_assert(FLATBUFFERS_VERSION_MAJOR == 23 &&
              FLATBUFFERS_VERSION_MINOR == 1 &&
              FLATBUFFERS_VERSION_REVISION == 21,
             "Non-compatible flatbuffers version included");

#include "hex-agent-data_generated.h"

namespace com {
namespace newrelic {
namespace mobile {
namespace fbs {

struct HexAgentDataBundle;
struct HexAgentDataBundleBuilder;
struct HexAgentDataBundleT;

struct HexAgentDataBundleT : public ::flatbuffers::NativeTable {
  typedef HexAgentDataBundle TableType;
  std::vector<std::unique_ptr<com::newrelic::mobile::fbs::HexAgentDataT>> hexAgentData{};
  HexAgentDataBundleT() = default;
  HexAgentDataBundleT(const HexAgentDataBundleT &o);
  HexAgentDataBundleT(HexAgentDataBundleT&&) FLATBUFFERS_NOEXCEPT = default;
  HexAgentDataBundleT &operator=(HexAgentDataBundleT o) FLATBUFFERS_NOEXCEPT;
};

struct HexAgentDataBundle FLATBUFFERS_FINAL_CLASS : private ::flatbuffers::Table {
  typedef HexAgentDataBundleT NativeTableType;
  typedef HexAgentDataBundleBuilder Builder;
  enum FlatBuffersVTableOffset FLATBUFFERS_VTABLE_UNDERLYING_TYPE {
    VT_HEXAGENTDATA = 4
  };
  const ::flatbuffers::Vector<::flatbuffers::Offset<com::newrelic::mobile::fbs::HexAgentData>> *hexAgentData() const {
    return GetPointer<const ::flatbuffers::Vector<::flatbuffers::Offset<com::newrelic::mobile::fbs::HexAgentData>> *>(VT_HEXAGENTDATA);
  }
  ::flatbuffers::Vector<::flatbuffers::Offset<com::newrelic::mobile::fbs::HexAgentData>> *mutable_hexAgentData() {
    return GetPointer<::flatbuffers::Vector<::flatbuffers::Offset<com::newrelic::mobile::fbs::HexAgentData>> *>(VT_HEXAGENTDATA);
  }
  bool Verify(::flatbuffers::Verifier &verifier) const {
    return VerifyTableStart(verifier) &&
           VerifyOffset(verifier, VT_HEXAGENTDATA) &&
           verifier.VerifyVector(hexAgentData()) &&
           verifier.VerifyVectorOfTables(hexAgentData()) &&
           verifier.EndTable();
  }
  HexAgentDataBundleT *UnPack(const ::flatbuffers::resolver_function_t *_resolver = nullptr) const;
  void UnPackTo(HexAgentDataBundleT *_o, const ::flatbuffers::resolver_function_t *_resolver = nullptr) const;
  static ::flatbuffers::Offset<HexAgentDataBundle> Pack(::flatbuffers::FlatBufferBuilder &_fbb, const HexAgentDataBundleT* _o, const ::flatbuffers::rehasher_function_t *_rehasher = nullptr);
};

struct HexAgentDataBundleBuilder {
  typedef HexAgentDataBundle Table;
  ::flatbuffers::FlatBufferBuilder &fbb_;
  ::flatbuffers::uoffset_t start_;
  void add_hexAgentData(::flatbuffers::Offset<::flatbuffers::Vector<::flatbuffers::Offset<com::newrelic::mobile::fbs::HexAgentData>>> hexAgentData) {
    fbb_.AddOffset(HexAgentDataBundle::VT_HEXAGENTDATA, hexAgentData);
  }
  explicit HexAgentDataBundleBuilder(::flatbuffers::FlatBufferBuilder &_fbb)
        : fbb_(_fbb) {
    start_ = fbb_.StartTable();
  }
  ::flatbuffers::Offset<HexAgentDataBundle> Finish() {
    const auto end = fbb_.EndTable(start_);
    auto o = ::flatbuffers::Offset<HexAgentDataBundle>(end);
    return o;
  }
};

inline ::flatbuffers::Offset<HexAgentDataBundle> CreateHexAgentDataBundle(
    ::flatbuffers::FlatBufferBuilder &_fbb,
    ::flatbuffers::Offset<::flatbuffers::Vector<::flatbuffers::Offset<com::newrelic::mobile::fbs::HexAgentData>>> hexAgentData = 0) {
  HexAgentDataBundleBuilder builder_(_fbb);
  builder_.add_hexAgentData(hexAgentData);
  return builder_.Finish();
}

inline ::flatbuffers::Offset<HexAgentDataBundle> CreateHexAgentDataBundleDirect(
    ::flatbuffers::FlatBufferBuilder &_fbb,
    const std::vector<::flatbuffers::Offset<com::newrelic::mobile::fbs::HexAgentData>> *hexAgentData = nullptr) {
  auto hexAgentData__ = hexAgentData ? _fbb.CreateVector<::flatbuffers::Offset<com::newrelic::mobile::fbs::HexAgentData>>(*hexAgentData) : 0;
  return com::newrelic::mobile::fbs::CreateHexAgentDataBundle(
      _fbb,
      hexAgentData__);
}

::flatbuffers::Offset<HexAgentDataBundle> CreateHexAgentDataBundle(::flatbuffers::FlatBufferBuilder &_fbb, const HexAgentDataBundleT *_o, const ::flatbuffers::rehasher_function_t *_rehasher = nullptr);

inline HexAgentDataBundleT::HexAgentDataBundleT(const HexAgentDataBundleT &o) {
  hexAgentData.reserve(o.hexAgentData.size());
  for (const auto &hexAgentData_ : o.hexAgentData) { hexAgentData.emplace_back((hexAgentData_) ? new com::newrelic::mobile::fbs::HexAgentDataT(*hexAgentData_) : nullptr); }
}

inline HexAgentDataBundleT &HexAgentDataBundleT::operator=(HexAgentDataBundleT o) FLATBUFFERS_NOEXCEPT {
  std::swap(hexAgentData, o.hexAgentData);
  return *this;
}

inline HexAgentDataBundleT *HexAgentDataBundle::UnPack(const ::flatbuffers::resolver_function_t *_resolver) const {
  auto _o = std::unique_ptr<HexAgentDataBundleT>(new HexAgentDataBundleT());
  UnPackTo(_o.get(), _resolver);
  return _o.release();
}

inline void HexAgentDataBundle::UnPackTo(HexAgentDataBundleT *_o, const ::flatbuffers::resolver_function_t *_resolver) const {
  (void)_o;
  (void)_resolver;
  { auto _e = hexAgentData(); if (_e) { _o->hexAgentData.resize(_e->size()); for (::flatbuffers::uoffset_t _i = 0; _i < _e->size(); _i++) { if(_o->hexAgentData[_i]) { _e->Get(_i)->UnPackTo(_o->hexAgentData[_i].get(), _resolver); } else { _o->hexAgentData[_i] = std::unique_ptr<com::newrelic::mobile::fbs::HexAgentDataT>(_e->Get(_i)->UnPack(_resolver)); }; } } else { _o->hexAgentData.resize(0); } }
}

inline ::flatbuffers::Offset<HexAgentDataBundle> HexAgentDataBundle::Pack(::flatbuffers::FlatBufferBuilder &_fbb, const HexAgentDataBundleT* _o, const ::flatbuffers::rehasher_function_t *_rehasher) {
  return CreateHexAgentDataBundle(_fbb, _o, _rehasher);
}

inline ::flatbuffers::Offset<HexAgentDataBundle> CreateHexAgentDataBundle(::flatbuffers::FlatBufferBuilder &_fbb, const HexAgentDataBundleT *_o, const ::flatbuffers::rehasher_function_t *_rehasher) {
  (void)_rehasher;
  (void)_o;
  struct _VectorArgs { ::flatbuffers::FlatBufferBuilder *__fbb; const HexAgentDataBundleT* __o; const ::flatbuffers::rehasher_function_t *__rehasher; } _va = { &_fbb, _o, _rehasher}; (void)_va;
  auto _hexAgentData = _o->hexAgentData.size() ? _fbb.CreateVector<::flatbuffers::Offset<com::newrelic::mobile::fbs::HexAgentData>> (_o->hexAgentData.size(), [](size_t i, _VectorArgs *__va) { return CreateHexAgentData(*__va->__fbb, __va->__o->hexAgentData[i].get(), __va->__rehasher); }, &_va ) : 0;
  return com::newrelic::mobile::fbs::CreateHexAgentDataBundle(
      _fbb,
      _hexAgentData);
}

inline const com::newrelic::mobile::fbs::HexAgentDataBundle *GetHexAgentDataBundle(const void *buf) {
  return ::flatbuffers::GetRoot<com::newrelic::mobile::fbs::HexAgentDataBundle>(buf);
}

inline const com::newrelic::mobile::fbs::HexAgentDataBundle *GetSizePrefixedHexAgentDataBundle(const void *buf) {
  return ::flatbuffers::GetSizePrefixedRoot<com::newrelic::mobile::fbs::HexAgentDataBundle>(buf);
}

inline HexAgentDataBundle *GetMutableHexAgentDataBundle(void *buf) {
  return ::flatbuffers::GetMutableRoot<HexAgentDataBundle>(buf);
}

inline com::newrelic::mobile::fbs::HexAgentDataBundle *GetMutableSizePrefixedHexAgentDataBundle(void *buf) {
  return ::flatbuffers::GetMutableSizePrefixedRoot<com::newrelic::mobile::fbs::HexAgentDataBundle>(buf);
}

inline bool VerifyHexAgentDataBundleBuffer(
    ::flatbuffers::Verifier &verifier) {
  return verifier.VerifyBuffer<com::newrelic::mobile::fbs::HexAgentDataBundle>(nullptr);
}

inline bool VerifySizePrefixedHexAgentDataBundleBuffer(
    ::flatbuffers::Verifier &verifier) {
  return verifier.VerifySizePrefixedBuffer<com::newrelic::mobile::fbs::HexAgentDataBundle>(nullptr);
}

inline void FinishHexAgentDataBundleBuffer(
    ::flatbuffers::FlatBufferBuilder &fbb,
    ::flatbuffers::Offset<com::newrelic::mobile::fbs::HexAgentDataBundle> root) {
  fbb.Finish(root);
}

inline void FinishSizePrefixedHexAgentDataBundleBuffer(
    ::flatbuffers::FlatBufferBuilder &fbb,
    ::flatbuffers::Offset<com::newrelic::mobile::fbs::HexAgentDataBundle> root) {
  fbb.FinishSizePrefixed(root);
}

inline std::unique_ptr<com::newrelic::mobile::fbs::HexAgentDataBundleT> UnPackHexAgentDataBundle(
    const void *buf,
    const ::flatbuffers::resolver_function_t *res = nullptr) {
  return std::unique_ptr<com::newrelic::mobile::fbs::HexAgentDataBundleT>(GetHexAgentDataBundle(buf)->UnPack(res));
}

inline std::unique_ptr<com::newrelic::mobile::fbs::HexAgentDataBundleT> UnPackSizePrefixedHexAgentDataBundle(
    const void *buf,
    const ::flatbuffers::resolver_function_t *res = nullptr) {
  return std::unique_ptr<com::newrelic::mobile::fbs::HexAgentDataBundleT>(GetSizePrefixedHexAgentDataBundle(buf)->UnPack(res));
}

}  // namespace fbs
}  // namespace mobile
}  // namespace newrelic
}  // namespace com

#endif  // FLATBUFFERS_GENERATED_HEXAGENTDATABUNDLE_COM_NEWRELIC_MOBILE_FBS_H_
