-- Rosa Betania OTs - modelo inicial (Specs 000-003 vigentes al 2026-10-09).
-- Crea exclusivamente las 15 entidades documentadas en public.

CREATE SEQUENCE public.orden_trabajo_codigo_seq AS bigint START WITH 1 INCREMENT BY 1;

CREATE TABLE public.rol (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo text NOT NULL UNIQUE,
  nombre text NOT NULL,
  estado boolean NOT NULL DEFAULT true,
  creado_por_perfil_id integer,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer,
  modificado_en timestamptz
);

CREATE TABLE public.sector (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo text NOT NULL UNIQUE,
  nombre text NOT NULL,
  orden_flujo integer UNIQUE,
  participa_flujo boolean NOT NULL DEFAULT false,
  estado boolean NOT NULL DEFAULT true,
  creado_por_perfil_id integer,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer,
  modificado_en timestamptz,
  CONSTRAINT sector_flujo_check CHECK (
    (participa_flujo AND orden_flujo IS NOT NULL AND orden_flujo > 0)
    OR (NOT participa_flujo AND orden_flujo IS NULL)
  )
);

CREATE TABLE public.perfil_usuario (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  correo text NOT NULL UNIQUE,
  nombre text NOT NULL,
  contrasena_hash text,
  intentos_fallidos integer NOT NULL DEFAULT 0 CHECK (intentos_fallidos >= 0),
  bloqueado_hasta timestamptz,
  rol_id integer NOT NULL REFERENCES public.rol(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  sector_id integer REFERENCES public.sector(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  estado boolean NOT NULL DEFAULT true,
  creado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  modificado_en timestamptz
);

ALTER TABLE public.rol
  ADD CONSTRAINT rol_creado_por_perfil_id_fkey FOREIGN KEY (creado_por_perfil_id) REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT rol_modificado_por_perfil_id_fkey FOREIGN KEY (modificado_por_perfil_id) REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE public.sector
  ADD CONSTRAINT sector_creado_por_perfil_id_fkey FOREIGN KEY (creado_por_perfil_id) REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT sector_modificado_por_perfil_id_fkey FOREIGN KEY (modificado_por_perfil_id) REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT;

CREATE TABLE public.cliente (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre text NOT NULL,
  telefono text,
  correo text,
  estado boolean NOT NULL DEFAULT true,
  creado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  modificado_en timestamptz
);

CREATE TABLE public.tipo_material (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo text NOT NULL UNIQUE,
  nombre text NOT NULL,
  requiere_gramaje boolean NOT NULL,
  estado boolean NOT NULL DEFAULT true,
  creado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  modificado_en timestamptz
);

CREATE TABLE public.material (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tipo_material_id integer NOT NULL REFERENCES public.tipo_material(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  codigo text NOT NULL UNIQUE,
  descripcion text NOT NULL,
  estado boolean NOT NULL DEFAULT true,
  creado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  modificado_en timestamptz
);

CREATE TABLE public.gramaje (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  material_id integer NOT NULL REFERENCES public.material(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  valor numeric(12,3) NOT NULL CHECK (valor > 0),
  estado boolean NOT NULL DEFAULT true,
  creado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  modificado_en timestamptz,
  CONSTRAINT gramaje_material_id_valor_key UNIQUE (material_id, valor)
);

CREATE TABLE public.maquina (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre text NOT NULL UNIQUE,
  estado boolean NOT NULL DEFAULT true,
  creado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  modificado_en timestamptz
);

CREATE TABLE public.parametro (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  grupo_codigo text NOT NULL,
  valor_codigo text NOT NULL,
  descripcion text NOT NULL,
  estado boolean NOT NULL DEFAULT true,
  creado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  modificado_en timestamptz,
  CONSTRAINT parametro_grupo_valor_key UNIQUE (grupo_codigo, valor_codigo),
  CONSTRAINT parametro_grupo_check CHECK (grupo_codigo IN ('TIPO_TRABAJO','COLORIMETRIA','IMPRESION','MUESTRARIO','ACABADO','ESTADO_OT'))
);

CREATE FUNCTION public.parametro_id(p_grupo text, p_valor text)
RETURNS integer LANGUAGE sql STABLE SET search_path = ''
AS $$
  SELECT id FROM public.parametro
  WHERE grupo_codigo = p_grupo AND valor_codigo = p_valor
$$;

CREATE TABLE public.responsable_sector (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  sector_id integer NOT NULL REFERENCES public.sector(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  nombre text NOT NULL,
  estado boolean NOT NULL DEFAULT true,
  creado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  modificado_en timestamptz
);

CREATE TABLE public.orden_trabajo (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo_ot text NOT NULL DEFAULT nextval('public.orden_trabajo_codigo_seq'::regclass)::text UNIQUE,
  cliente_id integer NOT NULL REFERENCES public.cliente(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  fecha_ot date NOT NULL,
  cantidad integer NOT NULL CHECK (cantidad > 0),
  tipo_trabajo_parametro_id integer NOT NULL REFERENCES public.parametro(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  cantidad_paginas integer CHECK (cantidad_paginas IS NULL OR cantidad_paginas > 0),
  nombre_trabajo text NOT NULL,
  estado_ot_parametro_id integer NOT NULL DEFAULT public.parametro_id('ESTADO_OT','PENDIENTE') REFERENCES public.parametro(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  idempotencia_creacion uuid NOT NULL UNIQUE,
  terminado_en timestamptz,
  anulado_en timestamptz,
  creado_por_perfil_id integer NOT NULL REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  modificado_en timestamptz,
  CONSTRAINT orden_trabajo_cierre_check CHECK (NOT (terminado_en IS NOT NULL AND anulado_en IS NOT NULL))
);

CREATE TABLE public.ot_detalle (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  orden_trabajo_id integer NOT NULL REFERENCES public.orden_trabajo(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  numero_piso smallint NOT NULL CHECK (numero_piso BETWEEN 1 AND 3),
  material_id integer NOT NULL REFERENCES public.material(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  tamano_material_x numeric(12,3) NOT NULL,
  tamano_material_y numeric(12,3) NOT NULL,
  armado integer NOT NULL,
  formato integer NOT NULL,
  total_pliegos integer NOT NULL CHECK (total_pliegos > 0),
  colorimetria_parametro_id integer NOT NULL REFERENCES public.parametro(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  cara_color text NOT NULL CHECK (cara_color IN ('ANVERSO','REVERSO','AMBAS')),
  impresion_parametro_id integer NOT NULL REFERENCES public.parametro(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  maquina_id integer NOT NULL REFERENCES public.maquina(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  muestrario_parametro_id integer NOT NULL REFERENCES public.parametro(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  tamano_final_x numeric(12,3),
  tamano_final_y numeric(12,3),
  tamano_corte_x numeric(12,3),
  tamano_corte_y numeric(12,3),
  cara_acabado text CHECK (cara_acabado IS NULL OR cara_acabado IN ('ANVERSO','REVERSO','AMBAS')),
  creado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  creado_en timestamptz NOT NULL DEFAULT now(),
  modificado_por_perfil_id integer REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  modificado_en timestamptz,
  CONSTRAINT ot_detalle_orden_piso_key UNIQUE (orden_trabajo_id, numero_piso),
  CONSTRAINT ot_detalle_material_tamano_check CHECK (tamano_material_x > 0 AND tamano_material_y > 0),
  CONSTRAINT ot_detalle_armado_formato_check CHECK (armado > 0 AND formato > 0 AND formato >= armado),
  CONSTRAINT ot_detalle_tamano_final_check CHECK ((tamano_final_x IS NULL AND tamano_final_y IS NULL) OR (tamano_final_x > 0 AND tamano_final_y > 0)),
  CONSTRAINT ot_detalle_tamano_corte_check CHECK ((tamano_corte_x IS NULL AND tamano_corte_y IS NULL) OR (tamano_corte_x > 0 AND tamano_corte_y > 0))
);

CREATE TABLE public.ot_acabado (
  orden_trabajo_id integer NOT NULL REFERENCES public.orden_trabajo(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  acabado_parametro_id integer NOT NULL REFERENCES public.parametro(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  posicion text CHECK (posicion IS NULL OR posicion IN ('IZQUIERDA','ARRIBA')),
  creado_por_perfil_id integer NOT NULL REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  creado_en timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (orden_trabajo_id, acabado_parametro_id)
);

CREATE TABLE public.token_usuario (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  perfil_usuario_id integer NOT NULL REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  tipo text NOT NULL CHECK (tipo IN ('SESION','INVITACION','RECUPERACION')),
  token_hash text NOT NULL UNIQUE,
  creado_en timestamptz NOT NULL DEFAULT now(),
  expira_en timestamptz NOT NULL,
  usado_en timestamptz,
  revocado_en timestamptz,
  CONSTRAINT token_usuario_expiracion_check CHECK (expira_en > creado_en),
  CONSTRAINT token_usuario_uso_check CHECK (tipo <> 'SESION' OR usado_en IS NULL)
);

CREATE TABLE public.movimiento_ot (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  orden_trabajo_id integer NOT NULL REFERENCES public.orden_trabajo(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  sector_origen_id integer REFERENCES public.sector(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  sector_destino_id integer NOT NULL REFERENCES public.sector(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  responsable_sector_id integer NOT NULL REFERENCES public.responsable_sector(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  realizado_por_perfil_id integer NOT NULL REFERENCES public.perfil_usuario(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  tipo_movimiento text NOT NULL CHECK (tipo_movimiento IN ('INICIO','AVANCE','DEVOLUCION')),
  ocurrido_en timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT movimiento_ot_origen_check CHECK (
    (tipo_movimiento = 'INICIO' AND sector_origen_id IS NULL)
    OR (tipo_movimiento IN ('AVANCE','DEVOLUCION') AND sector_origen_id IS NOT NULL)
  ),
  CONSTRAINT movimiento_ot_sector_distinto_check CHECK (sector_origen_id IS NULL OR sector_origen_id <> sector_destino_id)
);

-- Integridad entre catalogos o filas que no puede expresarse con CHECK/FK simples.
CREATE FUNCTION public.validar_perfil_usuario()
RETURNS trigger LANGUAGE plpgsql SET search_path = ''
AS $$
DECLARE v_rol text;
BEGIN
  SELECT codigo INTO v_rol FROM public.rol WHERE id = NEW.rol_id;
  IF v_rol IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'rol_id no existe';
  END IF;
  IF v_rol = 'USUARIO' AND NEW.sector_id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'un perfil USUARIO requiere sector_id';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER perfil_usuario_validar
BEFORE INSERT OR UPDATE OF rol_id, sector_id ON public.perfil_usuario
FOR EACH ROW EXECUTE FUNCTION public.validar_perfil_usuario();

CREATE FUNCTION public.validar_orden_trabajo()
RETURNS trigger LANGUAGE plpgsql SET search_path = ''
AS $$
DECLARE
  v_tipo_grupo text;
  v_estado_grupo text;
  v_estado text;
BEGIN
  SELECT grupo_codigo INTO v_tipo_grupo FROM public.parametro WHERE id = NEW.tipo_trabajo_parametro_id;
  SELECT grupo_codigo, valor_codigo INTO v_estado_grupo, v_estado FROM public.parametro WHERE id = NEW.estado_ot_parametro_id;
  IF v_tipo_grupo IS DISTINCT FROM 'TIPO_TRABAJO' THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'tipo_trabajo_parametro_id debe pertenecer a TIPO_TRABAJO';
  END IF;
  IF v_estado_grupo IS DISTINCT FROM 'ESTADO_OT' THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'estado_ot_parametro_id debe pertenecer a ESTADO_OT';
  END IF;
  IF v_estado = 'TERMINADO' AND (NEW.terminado_en IS NULL OR NEW.anulado_en IS NOT NULL) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'TERMINADO requiere terminado_en y no permite anulado_en';
  ELSIF v_estado = 'ANULADO' AND (NEW.anulado_en IS NULL OR NEW.terminado_en IS NOT NULL) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'ANULADO requiere anulado_en y no permite terminado_en';
  ELSIF v_estado NOT IN ('TERMINADO','ANULADO') AND (NEW.terminado_en IS NOT NULL OR NEW.anulado_en IS NOT NULL) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'un estado no terminal no admite marcas de cierre';
  END IF;
  IF TG_OP = 'UPDATE' AND NEW.codigo_ot IS DISTINCT FROM OLD.codigo_ot THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'codigo_ot es estable';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER orden_trabajo_validar
BEFORE INSERT OR UPDATE ON public.orden_trabajo
FOR EACH ROW EXECUTE FUNCTION public.validar_orden_trabajo();

CREATE FUNCTION public.impedir_eliminar_orden_trabajo()
RETURNS trigger LANGUAGE plpgsql SET search_path = ''
AS $$
BEGIN
  RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'una orden de trabajo se anula y no se elimina';
END;
$$;
CREATE TRIGGER orden_trabajo_no_eliminar
BEFORE DELETE ON public.orden_trabajo
FOR EACH ROW EXECUTE FUNCTION public.impedir_eliminar_orden_trabajo();

CREATE FUNCTION public.validar_ot_detalle()
RETURNS trigger LANGUAGE plpgsql SET search_path = ''
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.parametro WHERE id = NEW.colorimetria_parametro_id AND grupo_codigo = 'COLORIMETRIA') THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'colorimetria_parametro_id debe pertenecer a COLORIMETRIA';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.parametro WHERE id = NEW.impresion_parametro_id AND grupo_codigo = 'IMPRESION') THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'impresion_parametro_id debe pertenecer a IMPRESION';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.parametro WHERE id = NEW.muestrario_parametro_id AND grupo_codigo = 'MUESTRARIO') THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'muestrario_parametro_id debe pertenecer a MUESTRARIO';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER ot_detalle_validar
BEFORE INSERT OR UPDATE ON public.ot_detalle
FOR EACH ROW EXECUTE FUNCTION public.validar_ot_detalle();

CREATE FUNCTION public.validar_pisos_consecutivos()
RETURNS trigger LANGUAGE plpgsql SET search_path = ''
AS $$
DECLARE
  v_ot integer := COALESCE(NEW.orden_trabajo_id, OLD.orden_trabajo_id);
  v_cantidad integer;
  v_minimo smallint;
  v_maximo smallint;
BEGIN
  SELECT count(*)::integer, min(numero_piso), max(numero_piso)
    INTO v_cantidad, v_minimo, v_maximo
    FROM public.ot_detalle WHERE orden_trabajo_id = v_ot;
  IF v_cantidad > 0 AND (v_minimo <> 1 OR v_maximo <> v_cantidad) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'los pisos deben ser consecutivos desde 1';
  END IF;
  RETURN NULL;
END;
$$;
CREATE CONSTRAINT TRIGGER ot_detalle_pisos_consecutivos
AFTER INSERT OR UPDATE OR DELETE ON public.ot_detalle
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION public.validar_pisos_consecutivos();

CREATE FUNCTION public.validar_ot_acabado()
RETURNS trigger LANGUAGE plpgsql SET search_path = ''
AS $$
DECLARE
  v_grupo text;
  v_codigo text;
BEGIN
  SELECT grupo_codigo, valor_codigo INTO v_grupo, v_codigo
  FROM public.parametro WHERE id = NEW.acabado_parametro_id;
  IF v_grupo IS DISTINCT FROM 'ACABADO' THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'acabado_parametro_id debe pertenecer a ACABADO';
  END IF;
  IF v_codigo IN ('PERFORADO','ENGOMADO','ANILLADO','ENGRAMPADO') AND NEW.posicion IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'este acabado requiere posicion';
  ELSIF v_codigo NOT IN ('PERFORADO','ENGOMADO','ANILLADO','ENGRAMPADO') AND NEW.posicion IS NOT NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'la posicion no aplica a este acabado';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER ot_acabado_validar
BEFORE INSERT OR UPDATE ON public.ot_acabado
FOR EACH ROW EXECUTE FUNCTION public.validar_ot_acabado();

CREATE FUNCTION public.validar_movimiento_ot()
RETURNS trigger LANGUAGE plpgsql SET search_path = ''
AS $$
DECLARE
  v_estado text;
  v_destino_activo boolean;
  v_destino_participa boolean;
  v_origen_orden integer;
  v_destino_orden integer;
  v_responsable_sector integer;
  v_responsable_activo boolean;
  v_ultimo_destino integer;
  v_tiene_movimientos boolean;
BEGIN
  PERFORM 1 FROM public.orden_trabajo WHERE id = NEW.orden_trabajo_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'orden_trabajo_id no existe';
  END IF;
  SELECT p.valor_codigo INTO v_estado
  FROM public.orden_trabajo ot JOIN public.parametro p ON p.id = ot.estado_ot_parametro_id
  WHERE ot.id = NEW.orden_trabajo_id;
  IF v_estado IN ('TERMINADO','ANULADO') THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'una OT terminal no admite movimientos';
  END IF;

  SELECT estado, participa_flujo, orden_flujo
  INTO v_destino_activo, v_destino_participa, v_destino_orden
  FROM public.sector WHERE id = NEW.sector_destino_id;
  IF NOT COALESCE(v_destino_activo,false) OR NOT COALESCE(v_destino_participa,false) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'el destino debe estar activo y participar en el flujo';
  END IF;

  SELECT sector_id, estado INTO v_responsable_sector, v_responsable_activo
  FROM public.responsable_sector WHERE id = NEW.responsable_sector_id;
  IF v_responsable_sector IS DISTINCT FROM NEW.sector_destino_id OR NOT COALESCE(v_responsable_activo,false) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'el responsable debe estar activo y pertenecer al destino';
  END IF;

  SELECT EXISTS (SELECT 1 FROM public.movimiento_ot WHERE orden_trabajo_id = NEW.orden_trabajo_id)
  INTO v_tiene_movimientos;
  SELECT sector_destino_id INTO v_ultimo_destino
  FROM public.movimiento_ot
  WHERE orden_trabajo_id = NEW.orden_trabajo_id
  ORDER BY ocurrido_en DESC, id DESC LIMIT 1;

  IF NOT v_tiene_movimientos THEN
    IF NEW.tipo_movimiento <> 'INICIO' OR NEW.sector_origen_id IS NOT NULL OR v_estado <> 'PENDIENTE' THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'el primer movimiento debe ser INICIO desde PENDIENTE con origen null';
    END IF;
  ELSE
    IF NEW.tipo_movimiento = 'INICIO' OR NEW.sector_origen_id IS DISTINCT FROM v_ultimo_destino OR v_estado <> 'EN_PROCESO' THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'el movimiento debe enlazar el ultimo destino de una OT EN_PROCESO';
    END IF;
    SELECT orden_flujo INTO v_origen_orden FROM public.sector WHERE id = NEW.sector_origen_id;
    IF NEW.tipo_movimiento = 'AVANCE' AND v_destino_orden <= v_origen_orden THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'AVANCE requiere un destino posterior';
    ELSIF NEW.tipo_movimiento = 'DEVOLUCION' AND v_destino_orden >= v_origen_orden THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'DEVOLUCION requiere un destino anterior';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER movimiento_ot_validar
BEFORE INSERT ON public.movimiento_ot
FOR EACH ROW EXECUTE FUNCTION public.validar_movimiento_ot();

CREATE FUNCTION public.procesar_inicio_movimiento_ot()
RETURNS trigger LANGUAGE plpgsql SET search_path = ''
AS $$
BEGIN
  IF NEW.tipo_movimiento = 'INICIO' THEN
    UPDATE public.orden_trabajo
    SET estado_ot_parametro_id = public.parametro_id('ESTADO_OT','EN_PROCESO'),
        modificado_por_perfil_id = NEW.realizado_por_perfil_id,
        modificado_en = NEW.ocurrido_en
    WHERE id = NEW.orden_trabajo_id;
  END IF;
  RETURN NULL;
END;
$$;
CREATE TRIGGER movimiento_ot_procesar_inicio
AFTER INSERT ON public.movimiento_ot
FOR EACH ROW EXECUTE FUNCTION public.procesar_inicio_movimiento_ot();

CREATE FUNCTION public.impedir_modificar_movimiento_ot()
RETURNS trigger LANGUAGE plpgsql SET search_path = ''
AS $$
BEGIN
  RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'movimiento_ot es historico e inmutable';
END;
$$;
CREATE TRIGGER movimiento_ot_inmutable
BEFORE UPDATE OR DELETE ON public.movimiento_ot
FOR EACH ROW EXECUTE FUNCTION public.impedir_modificar_movimiento_ot();

-- Indices para claves foraneas y recorridos frecuentes; PK/UNIQUE ya crean indices.
CREATE INDEX rol_creado_por_idx ON public.rol (creado_por_perfil_id);
CREATE INDEX rol_modificado_por_idx ON public.rol (modificado_por_perfil_id);
CREATE INDEX sector_creado_por_idx ON public.sector (creado_por_perfil_id);
CREATE INDEX sector_modificado_por_idx ON public.sector (modificado_por_perfil_id);
CREATE INDEX perfil_usuario_rol_idx ON public.perfil_usuario (rol_id);
CREATE INDEX perfil_usuario_sector_idx ON public.perfil_usuario (sector_id);
CREATE INDEX perfil_usuario_creado_por_idx ON public.perfil_usuario (creado_por_perfil_id);
CREATE INDEX perfil_usuario_modificado_por_idx ON public.perfil_usuario (modificado_por_perfil_id);
CREATE INDEX cliente_creado_por_idx ON public.cliente (creado_por_perfil_id);
CREATE INDEX cliente_modificado_por_idx ON public.cliente (modificado_por_perfil_id);
CREATE INDEX tipo_material_creado_por_idx ON public.tipo_material (creado_por_perfil_id);
CREATE INDEX tipo_material_modificado_por_idx ON public.tipo_material (modificado_por_perfil_id);
CREATE INDEX material_tipo_idx ON public.material (tipo_material_id);
CREATE INDEX material_creado_por_idx ON public.material (creado_por_perfil_id);
CREATE INDEX material_modificado_por_idx ON public.material (modificado_por_perfil_id);
CREATE INDEX gramaje_creado_por_idx ON public.gramaje (creado_por_perfil_id);
CREATE INDEX gramaje_modificado_por_idx ON public.gramaje (modificado_por_perfil_id);
CREATE INDEX maquina_creado_por_idx ON public.maquina (creado_por_perfil_id);
CREATE INDEX maquina_modificado_por_idx ON public.maquina (modificado_por_perfil_id);
CREATE INDEX parametro_creado_por_idx ON public.parametro (creado_por_perfil_id);
CREATE INDEX parametro_modificado_por_idx ON public.parametro (modificado_por_perfil_id);
CREATE INDEX responsable_sector_sector_idx ON public.responsable_sector (sector_id);
CREATE INDEX responsable_sector_creado_por_idx ON public.responsable_sector (creado_por_perfil_id);
CREATE INDEX responsable_sector_modificado_por_idx ON public.responsable_sector (modificado_por_perfil_id);
CREATE INDEX orden_trabajo_cliente_idx ON public.orden_trabajo (cliente_id);
CREATE INDEX orden_trabajo_tipo_idx ON public.orden_trabajo (tipo_trabajo_parametro_id);
CREATE INDEX orden_trabajo_estado_idx ON public.orden_trabajo (estado_ot_parametro_id);
CREATE INDEX orden_trabajo_creado_por_idx ON public.orden_trabajo (creado_por_perfil_id);
CREATE INDEX orden_trabajo_modificado_por_idx ON public.orden_trabajo (modificado_por_perfil_id);
CREATE INDEX ot_detalle_material_idx ON public.ot_detalle (material_id);
CREATE INDEX ot_detalle_colorimetria_idx ON public.ot_detalle (colorimetria_parametro_id);
CREATE INDEX ot_detalle_impresion_idx ON public.ot_detalle (impresion_parametro_id);
CREATE INDEX ot_detalle_maquina_idx ON public.ot_detalle (maquina_id);
CREATE INDEX ot_detalle_muestrario_idx ON public.ot_detalle (muestrario_parametro_id);
CREATE INDEX ot_detalle_creado_por_idx ON public.ot_detalle (creado_por_perfil_id);
CREATE INDEX ot_detalle_modificado_por_idx ON public.ot_detalle (modificado_por_perfil_id);
CREATE INDEX ot_acabado_acabado_idx ON public.ot_acabado (acabado_parametro_id);
CREATE INDEX ot_acabado_creado_por_idx ON public.ot_acabado (creado_por_perfil_id);
CREATE INDEX token_usuario_perfil_tipo_expira_idx ON public.token_usuario (perfil_usuario_id, tipo, expira_en);
CREATE INDEX movimiento_ot_recorrido_idx ON public.movimiento_ot (orden_trabajo_id, ocurrido_en, id);
CREATE INDEX movimiento_ot_origen_idx ON public.movimiento_ot (sector_origen_id);
CREATE INDEX movimiento_ot_destino_idx ON public.movimiento_ot (sector_destino_id);
CREATE INDEX movimiento_ot_responsable_idx ON public.movimiento_ot (responsable_sector_id);
CREATE INDEX movimiento_ot_actor_idx ON public.movimiento_ot (realizado_por_perfil_id);

-- Seeds expresamente definidos por Spec 002 y Spec 003.
INSERT INTO public.rol (codigo, nombre) VALUES
  ('ADMINISTRADOR','Administrador'),
  ('USUARIO','Usuario');

INSERT INTO public.sector (codigo, nombre, orden_flujo, participa_flujo) VALUES
  ('DISENO','DISEÑO',1,true),
  ('PRENSA','PRENSA',2,true),
  ('PRE_ACABADO','PRE ACABADO',3,true),
  ('PRODUCCION','PRODUCCIÓN',4,true),
  ('ALMACEN','ALMACÉN',NULL,false);

INSERT INTO public.parametro (grupo_codigo, valor_codigo, descripcion) VALUES
  ('ESTADO_OT','PENDIENTE','Pendiente'),
  ('ESTADO_OT','EN_PROCESO','En proceso'),
  ('ESTADO_OT','TERMINADO','Terminado'),
  ('ESTADO_OT','ANULADO','Anulado'),
  ('COLORIMETRIA','FULL_COLOR','Full color'),
  ('COLORIMETRIA','PANTONE','Pantone'),
  ('COLORIMETRIA','FULL_MAS_PANTONE','Full + Pantone'),
  ('IMPRESION','TIRO_Y_VOLTEO','Tiro y volteo'),
  ('IMPRESION','TIRA_Y_RETIRA','Tira y retira'),
  ('IMPRESION','CAMBIO_DE_PINZA','Cambio de pinza'),
  ('MUESTRARIO','APROBACION_EN_MAQUINA','Aprobación en máquina'),
  ('MUESTRARIO','PRUEBA_DE_COLOR','Prueba de color'),
  ('MUESTRARIO','MUESTRA_FISICA','Muestra física'),
  ('MUESTRARIO','MUESTRA_DIGITAL','Muestra digital'),
  ('MUESTRARIO','IMPRESION_DE_ESCRITORIO','Impresión de escritorio'),
  ('ACABADO','PERFORADO','Perforado'),
  ('ACABADO','ENGOMADO','Engomado'),
  ('ACABADO','ANILLADO','Anillado'),
  ('ACABADO','ENGRAMPADO','Engrampado');

-- El Data API y Supabase Auth no forman parte de la arquitectura vigente.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon, authenticated;
REVOKE ALL ON FUNCTION public.parametro_id(text,text) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.validar_perfil_usuario() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.validar_orden_trabajo() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.impedir_eliminar_orden_trabajo() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.validar_ot_detalle() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.validar_pisos_consecutivos() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.validar_ot_acabado() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.validar_movimiento_ot() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.procesar_inicio_movimiento_ot() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.impedir_modificar_movimiento_ot() FROM PUBLIC, anon, authenticated;

-- Defensa por defecto en el esquema expuesto: RLS habilitada sin politicas de Data API.
ALTER TABLE public.cliente ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orden_trabajo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ot_detalle ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tipo_material ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.material ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gramaje ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maquina ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parametro ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ot_acabado ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rol ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.perfil_usuario ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.token_usuario ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sector ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.responsable_sector ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimiento_ot ENABLE ROW LEVEL SECURITY;
